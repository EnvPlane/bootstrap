package gitops

import (
	"context"
	"encoding/json"
	"io"
	"net/http"
	"strings"
	"testing"
)

type testRoundTripper func(*http.Request) (*http.Response, error)

func (f testRoundTripper) RoundTrip(r *http.Request) (*http.Response, error) {
	return f(r)
}

func TestPullRequestServiceCreatesGitHubPullRequest(t *testing.T) {
	var gotPath string
	var gotAuth string
	var gotPayload map[string]string

	client := &http.Client{
		Transport: testRoundTripper(func(r *http.Request) (*http.Response, error) {
			gotPath = r.URL.Path
			gotAuth = r.Header.Get("Authorization")
			if err := json.NewDecoder(r.Body).Decode(&gotPayload); err != nil {
				t.Fatalf("decode payload: %v", err)
			}
			return &http.Response{
				StatusCode: http.StatusOK,
				Header:     http.Header{"Content-Type": {"application/json"}},
				Body:       io.NopCloser(strings.NewReader(`{"html_url":"https://github.com/acme/gitops/pull/7","number":7}`)),
			}, nil
		}),
	}

	result, err := PullRequestService{client: client}.Create(context.Background(), PullRequestRequest{
		Provider: "github",
		APIBase:  "https://api.github.com",
		Token:    "token",
		RepoURL:  "https://github.com/acme/gitops.git",
		Title:    "EnvPilot pr-123",
		Body:     "body",
		Head:     "envpilot/pr-123",
		Base:     "main",
	})
	if err != nil {
		t.Fatalf("create pr: %v", err)
	}
	if gotPath != "/repos/acme/gitops/pulls" {
		t.Fatalf("path = %q", gotPath)
	}
	if gotAuth != "Bearer token" {
		t.Fatalf("auth = %q", gotAuth)
	}
	if gotPayload["head"] != "envpilot/pr-123" || gotPayload["base"] != "main" {
		t.Fatalf("payload = %#v", gotPayload)
	}
	if result.URL != "https://github.com/acme/gitops/pull/7" || result.Number != "7" {
		t.Fatalf("result = %+v", result)
	}
}

func TestRepositoryPathNormalizesHTTPSAndSSHURLs(t *testing.T) {
	for _, input := range []string{
		"https://github.com/acme/gitops.git",
		"git@github.com:acme/gitops.git",
	} {
		path, err := RepositoryPath(input)
		if err != nil {
			t.Fatalf("repository path: %v", err)
		}
		if path != "acme/gitops" {
			t.Fatalf("path for %q = %q", input, path)
		}
	}
}
