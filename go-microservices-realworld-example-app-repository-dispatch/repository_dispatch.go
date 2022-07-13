package repository_dispatch

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
)

type body struct {
	EventType string `json:"event_type"`
}

func newBody(eventType string) body {
	return body{EventType: eventType}
}

func RepositoryDispatch(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	repoOwner := os.Getenv("REPO_OWNER")
	if len(repoOwner) == 0 {
		http.Error(w, "An error occurred", http.StatusInternalServerError)
		panic("Environment variable REPO_OWNER must be set")
	}

	repo := os.Getenv("REPO")
	if len(repoOwner) == 0 {
		http.Error(w, "An error occurred", http.StatusInternalServerError)
		panic("Environment variable REPO must be set")
	}

	eventType := os.Getenv("EVENT_TYPE")
	if len(eventType) == 0 {
		http.Error(w, "An error occurred", http.StatusInternalServerError)
		panic("Environment variable EVENT_TYPE must be set")
	}

	githubToken := os.Getenv("GITHUB_TOKEN")
	if len(eventType) == 0 {
		http.Error(w, "An error occurred", http.StatusInternalServerError)
		panic("Environment variable GITHUB_TOKEN must be set")
	}

	requestBody, err := json.Marshal(newBody(eventType))
	if err != nil {
		http.Error(w, "An error occurred", http.StatusInternalServerError)
		panic(fmt.Sprintf("Error marshalling request body for eventType %s", eventType))
	}

	url := fmt.Sprintf("https://api.github.com/repos/%s/%s/dispatches", repoOwner, repo)

	client := &http.Client{}

	req, err := http.NewRequest("POST", url, bytes.NewBuffer(requestBody))
	if err != nil {
		http.Error(w, "An error occurred", http.StatusInternalServerError)
		panic(fmt.Sprintf("Error creating new request. url %s, requestBody: %v", url, requestBody))
	}

	req.Header.Set("Authorization", fmt.Sprintf("token %s", githubToken))
	req.Header.Set("accept", "application/vnd.github+json")
	req.Header.Set("content-type", "application/json")

	response, err := client.Do(req)
	if err != nil {
		http.Error(w, "An error occurred", http.StatusInternalServerError)
		panic(err)
	}

	defer response.Body.Close()

	if response.StatusCode != http.StatusNoContent {
		responseBodyBytes, err := io.ReadAll(response.Body)
		if err != nil {
			http.Error(w, "An error occurred", http.StatusInternalServerError)
			panic(err)
		}
		responseBodyString := string(responseBodyBytes)
		http.Error(w, "An error occurred", http.StatusInternalServerError)
		panic(responseBodyString)
	}

	w.WriteHeader(http.StatusNoContent)
}
