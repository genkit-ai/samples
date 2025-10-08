package main

import (
	"sync"

	"github.com/firebase/genkit/go/ai"
)

var (
	history = make(map[string][]*ai.Message)
	mu      sync.RWMutex
)

func LoadHistory(sessionID string) []*ai.Message {
	mu.RLock()
	defer mu.RUnlock()
	return history[sessionID]
}

func SaveHistory(sessionID string, messages []*ai.Message) {
	mu.Lock()
	defer mu.Unlock()
	history[sessionID] = messages
}
