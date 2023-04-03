package main

import (
	"crypto/sha256"
	"errors"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path"
	"strings"

	"github.com/media-kit/libmpv-darwin-build/pkg/lock"
)

func main() {
	lockFile := os.Args[1:][0]
	destDir := os.Args[1:][1]

	lock, err := lock.ParseLock(lockFile)
	if err != nil {
		log.Fatal(err)
	}

	for name := range lock {
		dep := lock[name]
		ext := parseExt(dep.URL, 2)

		tmpName := fmt.Sprintf(".%s-%s%s.tmp", name, dep.Version, ext)
		tmpPath := path.Join(destDir, tmpName)

		destName := fmt.Sprintf("%s-%s%s", name, dep.Version, ext)
		destPath := path.Join(destDir, destName)

		log.Println(destPath)

		err := download(dep.URL, tmpPath)
		if err != nil {
			log.Fatalf("%s: %s", destPath, err)
		}

		err = check(tmpPath, dep.Sha256)
		if err != nil {
			log.Fatalf("%s: %s", destPath, err)
		}

		err = os.Rename(tmpPath, destPath)
		if err != nil {
			log.Fatalf("%s: %s", destPath, err)
		}
	}
}

func parseExt(filename string, count int) string {
	var exts []string

	for i := 0; i < count; i++ {
		ext := path.Ext(filename)
		filename = strings.TrimSuffix(filename, ext)
		exts = append(exts, ext)
	}

	return strings.Join(reverse(exts), "")
}

func reverse(s []string) []string {
	var r []string
	for i := len(s) - 1; i >= 0; i-- {
		r = append(r, s[i])
	}
	return r
}

func download(url, path string) error {
	file, err := os.Create(path)
	if err != nil {
		return fmt.Errorf("download: %w", err)
	}
	defer file.Close()

	req, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		return fmt.Errorf("download: %w", err)
	}

	res, err := http.DefaultClient.Do(req)
	if err != nil {
		return fmt.Errorf("download: %w", err)
	}
	defer res.Body.Close()

	if res.StatusCode != http.StatusOK {
		return fmt.Errorf(
			"download: status error: %d!=%d", res.StatusCode, http.StatusOK,
		)
	}

	_, err = io.Copy(file, res.Body)
	if err != nil {
		return fmt.Errorf("download: %w", err)
	}

	return nil
}

func check(path, sha256sum string) error {
	file, err := os.Open(path)
	if err != nil {
		return fmt.Errorf("check: %w", err)
	}
	defer file.Close()

	hash := sha256.New()

	_, err = io.Copy(hash, file)
	if err != nil {
		return fmt.Errorf("check: %w", err)
	}

	sum := fmt.Sprintf("%x", hash.Sum(nil))
	if sum != sha256sum {
		return errors.New("check: cheksums not matching")
	}

	return nil
}
