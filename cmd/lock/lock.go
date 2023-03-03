package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"os/exec"

	"github.com/birros/libmpv-build-wip/pkg/models"
	"gopkg.in/yaml.v3"
)

func main() {
	log.SetFlags(log.Lshortfile)

	packages := os.Args[1:]
	lock := NewLock(packages...)

	var buf bytes.Buffer
	e := yaml.NewEncoder(&buf)
	e.SetIndent(2)

	e.Encode(lock)
	err := e.Close()
	if err != nil {
		log.Fatalln(err)
	}

	text := string(buf.Bytes())

	fmt.Println(text)
}

func NewLock(packages ...string) models.Lock {
	var lock models.Lock = models.Lock{}

	for _, name := range packages {
		dep := NewDep(name)
		lock[name] = dep
	}

	return lock
}

func NewDep(packageName string) models.Dep {
	return DepFromBrewInfo(BrewInfo(packageName))
}

func DepFromBrewInfo(info BrewInfoResponse) models.Dep {
	return models.Dep{
		Version: info.Versions.Stable,
		URL:     info.Urls.Stable.URL,
		Sha256:  info.Urls.Stable.Checksum,
	}
}

func BrewInfo(packageName string) BrewInfoResponse {
	out, err := exec.Command("brew", "info", "--json", packageName).Output()
	if err != nil {
		log.Fatalf("%s: err", packageName)
	}

	var resp []BrewInfoResponse
	err = json.Unmarshal(out, &resp)
	if err != nil {
		log.Fatalln(err)
	}

	if len(resp) != 1 {
		log.Fatalf("brew info: %s: not found", packageName)
	}

	info := resp[0]

	if info.Name != packageName {
		log.Fatalf(
			"brew info: %s: %s != %s", packageName, packageName, info.Name,
		)
	}

	return info
}

type BrewInfoResponse struct {
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
