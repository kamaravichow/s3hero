// Package config manages S3Hero configuration profiles
package config

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
)

// ProviderType represents the S3 provider type
type ProviderType string

const (
	ProviderAWS        ProviderType = "aws"
	ProviderCloudflare ProviderType = "cloudflare"
	ProviderCustom     ProviderType = "custom"
)

// Profile represents an S3 connection profile
type Profile struct {
	Name            string       `json:"name"`
	Provider        ProviderType `json:"provider"`
	AccessKeyID     string       `json:"access_key_id"`
	SecretAccessKey string       `json:"secret_access_key"`
	Region          string       `json:"region"`
	Endpoint        string       `json:"endpoint,omitempty"`
	AccountID       string       `json:"account_id,omitempty"` // For Cloudflare R2
}

// Config holds all S3Hero configuration
type Config struct {
	DefaultProfile string              `json:"default_profile"`
	Profiles       map[string]*Profile `json:"profiles"`
}

// Manager handles configuration operations
type Manager struct {
	configPath string
	config     *Config
}

// NewManager creates a new configuration manager
func NewManager() (*Manager, error) {
	configDir, err := getConfigDir()
	if err != nil {
		return nil, fmt.Errorf("failed to get config directory: %w", err)
	}

	configPath := filepath.Join(configDir, "config.json")

	m := &Manager{
		configPath: configPath,
		config: &Config{
			Profiles: make(map[string]*Profile),
		},
	}

	// Try to load existing config
	if err := m.Load(); err != nil && !os.IsNotExist(err) {
		return nil, fmt.Errorf("failed to load config: %w", err)
	}

	return m, nil
}

// getConfigDir returns the configuration directory path
func getConfigDir() (string, error) {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}

	configDir := filepath.Join(homeDir, ".s3hero")
	if err := os.MkdirAll(configDir, 0700); err != nil {
		return "", err
	}

	return configDir, nil
}

// Load reads the configuration from disk
func (m *Manager) Load() error {
	data, err := os.ReadFile(m.configPath)
	if err != nil {
		return err
	}

	return json.Unmarshal(data, m.config)
}

// Save writes the configuration to disk
func (m *Manager) Save() error {
	data, err := json.MarshalIndent(m.config, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal config: %w", err)
	}

	return os.WriteFile(m.configPath, data, 0600)
}

// AddProfile adds or updates a profile
func (m *Manager) AddProfile(profile *Profile) error {
	if profile.Name == "" {
		return fmt.Errorf("profile name is required")
	}

	m.config.Profiles[profile.Name] = profile

	// Set as default if it's the first profile
	if len(m.config.Profiles) == 1 {
		m.config.DefaultProfile = profile.Name
	}

	return m.Save()
}

// GetProfile retrieves a profile by name
func (m *Manager) GetProfile(name string) (*Profile, error) {
	if name == "" {
		name = m.config.DefaultProfile
	}

	if name == "" {
		return nil, fmt.Errorf("no profile specified and no default profile set")
	}

	profile, exists := m.config.Profiles[name]
	if !exists {
		return nil, fmt.Errorf("profile '%s' not found", name)
	}

	return profile, nil
}

// DeleteProfile removes a profile
func (m *Manager) DeleteProfile(name string) error {
	if _, exists := m.config.Profiles[name]; !exists {
		return fmt.Errorf("profile '%s' not found", name)
	}

	delete(m.config.Profiles, name)

	// Update default if necessary
	if m.config.DefaultProfile == name {
		m.config.DefaultProfile = ""
		for n := range m.config.Profiles {
			m.config.DefaultProfile = n
			break
		}
	}

	return m.Save()
}

// ListProfiles returns all profile names
func (m *Manager) ListProfiles() []string {
	names := make([]string, 0, len(m.config.Profiles))
	for name := range m.config.Profiles {
		names = append(names, name)
	}
	return names
}

// SetDefault sets the default profile
func (m *Manager) SetDefault(name string) error {
	if _, exists := m.config.Profiles[name]; !exists {
		return fmt.Errorf("profile '%s' not found", name)
	}

	m.config.DefaultProfile = name
	return m.Save()
}

// GetDefault returns the default profile name
func (m *Manager) GetDefault() string {
	return m.config.DefaultProfile
}

// GetConfig returns the full configuration
func (m *Manager) GetConfig() *Config {
	return m.config
}
