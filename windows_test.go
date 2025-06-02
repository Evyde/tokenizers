//go:build windows

package tokenizers_test

import (
	"runtime"
	"testing"

	"github.com/daulet/tokenizers"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestWindowsCompatibility tests that the library works correctly on Windows
func TestWindowsCompatibility(t *testing.T) {
	// Verify we're running on Windows
	assert.Equal(t, "windows", runtime.GOOS, "This test should only run on Windows")

	// Test basic functionality with embedded tokenizer
	tk, err := tokenizers.FromBytes(embeddedBytes)
	require.NoError(t, err, "Failed to create tokenizer from bytes on Windows")
	defer tk.Close()

	// Test encoding
	text := "Hello, Windows world!"
	ids, tokens := tk.Encode(text, false)
	require.NotEmpty(t, ids, "Encoding should produce token IDs")
	require.NotEmpty(t, tokens, "Encoding should produce tokens")

	// Test decoding
	decoded := tk.Decode(ids, false)
	require.NotEmpty(t, decoded, "Decoding should produce text")

	// Test vocab size
	vocabSize := tk.VocabSize()
	require.Greater(t, vocabSize, uint32(0), "Vocab size should be greater than 0")

	t.Logf("Windows compatibility test passed:")
	t.Logf("  - Text: %s", text)
	t.Logf("  - Token IDs: %v", ids)
	t.Logf("  - Tokens: %v", tokens)
	t.Logf("  - Decoded: %s", decoded)
	t.Logf("  - Vocab size: %d", vocabSize)
}

// TestWindowsEncodeWithOptions tests encoding with options on Windows
func TestWindowsEncodeWithOptions(t *testing.T) {
	assert.Equal(t, "windows", runtime.GOOS, "This test should only run on Windows")

	tk, err := tokenizers.FromBytes(embeddedBytes)
	require.NoError(t, err)
	defer tk.Close()

	text := "Windows tokenizer test"
	encoding := tk.EncodeWithOptions(text, true, tokenizers.WithReturnAllAttributes())

	require.NotEmpty(t, encoding.IDs, "Should have token IDs")
	require.NotEmpty(t, encoding.Tokens, "Should have tokens")
	require.NotEmpty(t, encoding.AttentionMask, "Should have attention mask")
	require.NotEmpty(t, encoding.TypeIDs, "Should have type IDs")
	require.NotEmpty(t, encoding.Offsets, "Should have offsets")

	t.Logf("Windows encoding with options test passed:")
	t.Logf("  - IDs: %v", encoding.IDs)
	t.Logf("  - Tokens: %v", encoding.Tokens)
	t.Logf("  - Attention mask: %v", encoding.AttentionMask)
}

// TestWindowsMemoryManagement tests that memory is properly managed on Windows
func TestWindowsMemoryManagement(t *testing.T) {
	assert.Equal(t, "windows", runtime.GOOS, "This test should only run on Windows")

	// Create and close multiple tokenizers to test memory management
	for i := 0; i < 10; i++ {
		tk, err := tokenizers.FromBytes(embeddedBytes)
		require.NoError(t, err, "Failed to create tokenizer %d", i)

		// Perform some operations
		ids, _ := tk.Encode("test", false)
		require.NotEmpty(t, ids, "Encoding failed for tokenizer %d", i)

		// Close the tokenizer
		err = tk.Close()
		require.NoError(t, err, "Failed to close tokenizer %d", i)
	}

	t.Log("Windows memory management test passed")
}
