package sca

import (
	"context"

	"github.com/xmirrorsecurity/opensca-cli/opensca/model"
	"github.com/xmirrorsecurity/opensca-cli/opensca/sca/golang"
	"github.com/xmirrorsecurity/opensca-cli/opensca/sca/java"
	"github.com/xmirrorsecurity/opensca-cli/opensca/sca/javascript"
	"github.com/xmirrorsecurity/opensca-cli/opensca/sca/python"
)

type Sca interface {
	Filter(relpath string) bool
	Sca(ctx context.Context, parent *model.File, files []*model.File) []*model.DepGraph
}

var allSca = []Sca{
	java.Sca{},
	python.Sca{},
	javascript.Sca{},
	golang.Sca{},
}

func Filter(relpath string) bool {
	for _, sca := range allSca {
		if sca.Filter(relpath) {
			return true
		}
	}
	return false
}

func Do(ctx context.Context, do func(dep *model.DepGraph)) func(parent *model.File, files []*model.File) {
	return func(parent *model.File, files []*model.File) {
		for _, sca := range allSca {
			for _, dep := range sca.Sca(ctx, parent, files) {
				do(dep)
			}
		}
	}
}
