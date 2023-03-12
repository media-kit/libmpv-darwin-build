package main

import (
	"fmt"
	"html/template"
	"log"
	"os"
	"strings"

	"github.com/birros/libmpv-build-wip/pkg/lock"
	tool_versions "github.com/birros/libmpv-build-wip/pkg/tool-versions"
	"github.com/birros/libmpv-build-wip/pkg/versions"
)

var templ = `## Dependencies

{{.DependenciesTable}}

## Tools

{{.ToolsTable}}
`

func main() {
	lockFile := os.Args[1:][0]

	lock, err := lock.ParseLock(lockFile)
	if err != nil {
		log.Fatal(err)
	}

	lvm := lockToVersionsMap(lock)

	tvm, err := tool_versions.BuildToolVersions()
	if err != nil {
		log.Fatal(err)
	}

	tpl := template.New("release-note")
	tpl.Parse(templ)

	type Data = struct {
		DependenciesTable string
		ToolsTable        string
	}

	err = tpl.Execute(os.Stdout, Data{
		DependenciesTable: versionsMapToMarkdownTable(lvm, "Name", "Version"),
		ToolsTable:        versionsMapToMarkdownTable(tvm, "Name", "Version"),
	})
	if err != nil {
		log.Fatal(err)
	}
}

func lockToVersionsMap(lock lock.Lock) versions.VersionsMap {
	out := versions.VersionsMap{}

	for name, dep := range lock {
		out[name] = dep.Version
	}

	return out
}

func versionsMapToMarkdownTable(
	vm versions.VersionsMap,
	keyName, valueName string,
) string {
	var out string

	out += fmt.Sprintf("| %s | %s |", keyName, valueName)

	out += "\n"
	out += fmt.Sprintf(
		"| %s | %s |",
		strings.Repeat("-", len(keyName)),
		strings.Repeat("-", len(valueName)),
	)

	for name, version := range vm {
		out += "\n"
		out += fmt.Sprintf("| %s | %s |", name, version)
	}

	return out
}
