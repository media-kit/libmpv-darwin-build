package models

type Lock = map[string]Dep

type Dep struct {
	Version string `yaml:"version"`
	URL     string `yaml:"url"`
	Sha256  string `yaml:"sha256"`
}
