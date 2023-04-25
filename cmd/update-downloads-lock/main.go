package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"

	"github.com/media-kit/libmpv-darwin-build/pkg/lock"
	"gopkg.in/yaml.v3"
)

func main() {
	log.SetFlags(log.Lshortfile)

	packages := os.Args[1:]
	lock, err := newLock(packages...)
	if err != nil {
		log.Fatal(err)
	}

	text, err := marshalLock(lock)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(text)
}

func newLock(packages ...string) (lock.Lock, error) {
	var lock lock.Lock = lock.Lock{}

	for _, name := range packages {
		dep, err := newDep(name)
		if err != nil {
			return nil, fmt.Errorf("newLock: %w", err)
		}

		if name == "libressl" {
			dep.URL = strings.Replace(
				dep.URL,
				"https://ftp.openbsd.org",
				"https://cdn.openbsd.org",
				1,
			)
		}

		lock[name] = *dep
	}

	return lock, nil
}

func newDep(packageName string) (*lock.Dep, error) {
	info, err := brewInfo(packageName)
	if err != nil {
		return nil, fmt.Errorf("newDep: %w", err)
	}

	dep := depFromBrewInfo(info)
	return dep, nil
}

func brewInfo(packageName string) (*brewInfoResponse, error) {
	out, err := exec.Command("brew", "info", "--json", packageName).Output()
	if err != nil {
		return nil, fmt.Errorf("brewInfo: %w", err)
	}

	var resp []brewInfoResponse
	err = json.Unmarshal(out, &resp)
	if err != nil {
		return nil, fmt.Errorf("brewInfo: %w", err)
	}

	if len(resp) != 1 {
		return nil, fmt.Errorf("brewInfo: not found")
	}

	info := resp[0]

	if info.Name != packageName {
		return nil, fmt.Errorf(
			"brewInfo: %s: %s != %s", packageName, packageName, info.Name,
		)
	}

	return &info, nil
}

type brewInfoResponse struct {
	Name     string `json:"name"`
	Versions struct {
		Stable string `json:"stable"`
	} `json:"versions"`
	Urls struct {
		Stable struct {
			URL      string `json:"url"`
			Checksum string `json:"checksum"`
		} `json:"stable"`
	} `json:"urls"`
}

func depFromBrewInfo(info *brewInfoResponse) *lock.Dep {
	return &lock.Dep{
		Version: info.Versions.Stable,
		URL:     info.Urls.Stable.URL,
		Sha256:  info.Urls.Stable.Checksum,
	}
}

func marshalLock(lock lock.Lock) (string, error) {
	var buf bytes.Buffer
	e := yaml.NewEncoder(&buf)
	e.SetIndent(2)

	e.Encode(lock)
	err := e.Close()
	if err != nil {
		return "", fmt.Errorf("marshalLock: %w", err)
	}

	text := string(buf.Bytes())

	return text, nil
}
