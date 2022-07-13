package repository_dispatch

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
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

type PubSubMessage struct {
	Data []byte `json:"data"`
}

func RepositoryDispatch(ctx context.Context, m PubSubMessage) error {
	repo := os.Getenv("REPO")
	if len(repo) == 0 {
		return errors.New("Environment variable REPO must be set")
	}

	eventType := os.Getenv("EVENT_TYPE")
	if len(eventType) == 0 {
		return errors.New("Environment variable EVENT_TYPE must be set")
	}

	githubToken := os.Getenv("GITHUB_TOKEN")
	if len(eventType) == 0 {
		return errors.New("Environment variable GITHUB_TOKEN must be set")
	}

	requestBody, err := json.Marshal(newBody(eventType))
	if err != nil {
		return fmt.Errorf("Error marshalling request body for eventType %s", eventType)
	}

	url := fmt.Sprintf("https://api.github.com/repos/%s/dispatches", repo)

	client := &http.Client{}

	req, err := http.NewRequest("POST", url, bytes.NewBuffer(requestBody))
	if err != nil {
		return fmt.Errorf("Error creating new request. url %s, requestBody: %v", url, requestBody)
	}

	req.Header.Set("Authorization", fmt.Sprintf("token %s", githubToken))
	req.Header.Set("accept", "application/vnd.github+json")
	req.Header.Set("content-type", "application/json")

	response, err := client.Do(req)
	if err != nil {
		return err
	}

	defer response.Body.Close()

	if response.StatusCode != http.StatusNoContent {
		responseBodyBytes, err := io.ReadAll(response.Body)
		if err != nil {
			return err
		}
		responseBodyString := string(responseBodyBytes)
		return errors.New(responseBodyString)
	}

	return nil
}
