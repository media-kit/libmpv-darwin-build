package lock

import (
	"fmt"
	"io"
	"os"

	"gopkg.in/yaml.v3"
)

type Lock = map[string]Dep

type Dep struct {
	Version string `yaml:"version"`
	URL     string `yaml:"url"`
	Sha256  string `yaml:"sha256"`
}

func ParseLock(path string) (Lock, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, fmt.Errorf("ParseLock: %w", err)
	}

	data, err := io.ReadAll(f)
	if err != nil {
		return nil, fmt.Errorf("ParseLock: %w", err)
	}

	var lock Lock
	err = yaml.Unmarshal(data, &lock)
	if err != nil {
		return nil, fmt.Errorf("ParseLock: %w", err)
	}

	return lock, nil
}
