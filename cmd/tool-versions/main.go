package main

import (
	"fmt"
	"log"

	tool_versions "github.com/birros/libmpv-build-wip/pkg/tool-versions"
	"github.com/birros/libmpv-build-wip/pkg/utils"
	"github.com/birros/libmpv-build-wip/pkg/versions"
)

func main() {
	tv, err := tool_versions.BuildToolVersions()
	if err != nil {
		log.Fatal(err)
	}

	out := marshalVersionsMap(tv)

	fmt.Println(out)
}

func marshalVersionsMap(vm versions.VersionsMap) string {
	var out string

	for _, name := range utils.SortedKeys(vm) {
		version := vm[name]
		out += fmt.Sprintf("%s %s\n", name, version)
	}

	return out
}
