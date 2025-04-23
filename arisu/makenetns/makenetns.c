#include <string.h>
#include <err.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#define _GNU_SOURCE
#include <sched.h>
#include <unistd.h>
#include <sys/wait.h>

#define PROC_NS_NET_PATH "/proc/self/ns/net"

#define IP_CMD_PATH "/sbin/ip"

#define runcmd(pathname, arg0, ...) \
	do { \
		_runcmd(pathname, (char * const[]){arg0, __VA_ARGS__, NULL}); \
	} while (0)

void _runcmd(const char *pathname, char *const argv[]);

int main(int argc, char *argv[])
{
	if (argc < 5 || (argc == 5 && strcmp(argv[4], "--") == 0))
	{
		fprintf(stderr, "Usage: %s <interface> <host-ip/subnet> <ns-ip/subnet> [--] <command> [args...]\n", "makenetns");
		exit(EXIT_FAILURE);
	}

	int oldns = open(PROC_NS_NET_PATH, O_RDONLY | O_CLOEXEC);
	if (oldns == -1)
		err(EXIT_FAILURE, "open(oldns)");

	if (unshare(CLONE_NEWNET) == -1)
		err(EXIT_FAILURE, "unshare");

	int newns = open(PROC_NS_NET_PATH, O_RDONLY | O_CLOEXEC);
	if (newns == -1)
		err(EXIT_FAILURE, "open(newns)");

	if (setns(oldns, 0) == -1)
		err(EXIT_FAILURE, "setns(oldns)");

	pid_t ppid = getpid();
	pid_t cpid = fork();
	if (cpid == -1)
		err(EXIT_FAILURE, "fork");

	if (cpid == 0)
	{
		if (setns(newns, 0) == -1)
			err(EXIT_FAILURE, "setns(newns)");

		char *splitstr;
		if ((splitstr = strchr(argv[2], '/')) != NULL)
			*splitstr = '\0';

		char ppidstr[24];
		snprintf(ppidstr, sizeof(ppidstr), "%d", ppid);

		runcmd(IP_CMD_PATH, "ip", "link", "set", "lo", "up");
		runcmd(IP_CMD_PATH, "ip", "link", "add", "eth0", "type", "veth", "peer", "name", argv[1]);
		runcmd(IP_CMD_PATH, "ip", "link", "set", "eth0", "up");
		runcmd(IP_CMD_PATH, "ip", "addr", "add", argv[3], "dev", "eth0");
		runcmd(IP_CMD_PATH, "ip", "route", "add", "default", "via", argv[2]);
		runcmd(IP_CMD_PATH, "ip", "link", "set", argv[1], "netns", ppidstr);

		return 0;
	}

	int status;
	if (waitpid(cpid, &status, 0) == -1)
		err(EXIT_FAILURE, "waitpid");

	if (!WIFEXITED(status) || WEXITSTATUS(status) != 0)
	{
		fprintf(stderr, "child helper failed\n");
		exit(EXIT_FAILURE);
	}

	runcmd(IP_CMD_PATH, "ip", "link", "set", argv[1], "up");
	runcmd(IP_CMD_PATH, "ip", "addr", "add", argv[2], "dev", argv[1]);

	if (setns(newns, 0) == -1)
		err(EXIT_FAILURE, "setns(newns)");

	if (strcmp(argv[4], "--") == 0)
		execvp(argv[5], &argv[5]);
	else
		execvp(argv[4], &argv[4]);

	err(EXIT_FAILURE, "execvp");
}

void _runcmd(const char *pathname, char *const argv[])
{
	pid_t pid = fork();
	if (pid == -1)
		err(EXIT_FAILURE, "fork");

	if (pid == 0)
	{
		execv(pathname, argv);
		err(EXIT_FAILURE, pathname);
	}

	int status;
	if (waitpid(pid, &status, 0) == -1)
		err(EXIT_FAILURE, "waitpid");

	if (!WIFEXITED(status) || WEXITSTATUS(status) != 0)
		exit(EXIT_FAILURE);
}
