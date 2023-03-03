package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path"
	"strings"

	"github.com/birros/libmpv-build-wip/pkg/models"
	"gopkg.in/yaml.v3"
)

func Reverse[T comparable](s []T) []T {
	var r []T
	for i := len(s) - 1; i >= 0; i-- {
		r = append(r, s[i])
	}
	return r
}

func Ext(filename string, count int) string {
	var exts []string

	for i := 0; i < count; i++ {
		ext := path.Ext(filename)
		filename = strings.TrimSuffix(filename, ext)
		exts = append(exts, ext)
	}

	return strings.Join(Reverse(exts), "")
}

func main() {
	lockFile := os.Args[1:][0]
	destDir := os.Args[1:][1]

	f, err := os.Open(lockFile)
	if err != nil {
		log.Fatalln(err)
	}

	data, err := io.ReadAll(f)
	if err != nil {
		log.Fatalln(err)
	}

	var lock models.Lock
	err = yaml.Unmarshal(data, &lock)
	if err != nil {
		log.Fatalln(err)
	}

	for name := range lock {
		dep := lock[name]

		ext := Ext(dep.URL, 2)
		filename := fmt.Sprintf("%s-%s%s", name, dep.Version, ext)
		destPath := path.Join(destDir, filename)

		log.Println(destPath)

		destFile, err := os.Create(destPath)
		if err != nil {
			log.Fatalln(err)
		}
		defer destFile.Close()

		req, err := http.NewRequest(http.MethodGet, dep.URL, nil)
		if err != nil {
			log.Fatalln(err)
		}

		res, err := http.DefaultClient.Do(req)
		if err != nil {
			log.Fatalln(err)
		}
		defer res.Body.Close()

		if res.StatusCode != http.StatusOK {
			log.Fatalln(
				fmt.Sprintf(
					"resp: error: %d!=%d", res.StatusCode, http.StatusOK,
				),
			)
		}

		_, err = io.Copy(destFile, res.Body)
		if err != nil {
			log.Fatalln(err)
		}

		// TODO: add checksum
	}
}
