package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
)

func main() {
	if len(os.Args) != 2 {
		fail("Usage: " + os.Args[0] + " [version prefix]")
	}

	versionPrefix := os.Args[1]

	resp, err := http.Get("https://go.dev/dl/?mode=json&include=all")
	if err != nil {
		fail("Error requesting Go version list: ", err)
	}

	data, err := func() ([]byte, error) {
		defer resp.Body.Close()
		return io.ReadAll(resp.Body)
	}()
	if err != nil {
		fail("Error reading response body: ", err)
	}

	var releases []struct {
		Version string `json:"version"`
	}
	if err := json.Unmarshal(data, &releases); err != nil {
		fail("Failed to parse releases JSON: ", err)
	}

	for _, r := range releases {
		if strings.HasPrefix(r.Version, versionPrefix) {
			fmt.Println(r.Version)
			return
		}
	}

	fail("No suitable Go version with prefix: \"" + versionPrefix + "\"")
}

func fail(v ...any) {
	fmt.Fprintln(os.Stderr, v...)
	os.Exit(1)
}
