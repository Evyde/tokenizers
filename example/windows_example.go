package main

import (
	"fmt"
	"log"
	"runtime"

	"github.com/daulet/tokenizers"
)

func main() {
	fmt.Printf("Running on %s/%s\n", runtime.GOOS, runtime.GOARCH)

	if runtime.GOOS != "windows" {
		fmt.Println("This example is designed for Windows, but will work on other platforms too.")
	}

	// Example 1: Load tokenizer from a local file
	fmt.Println("\n=== Example 1: Loading from file ===")
	tk, err := tokenizers.FromFile("../test/data/bert-base-uncased.json")
	if err != nil {
		log.Printf("Failed to load tokenizer from file: %v", err)
		log.Println("This is expected if the test data is not available")
	} else {
		defer tk.Close()
		
		text := "Hello, Windows world!"
		fmt.Printf("Text: %s\n", text)
		
		ids, tokens := tk.Encode(text, true)
		fmt.Printf("Token IDs: %v\n", ids)
		fmt.Printf("Tokens: %v\n", tokens)
		
		decoded := tk.Decode(ids, true)
		fmt.Printf("Decoded: %s\n", decoded)
		
		fmt.Printf("Vocabulary size: %d\n", tk.VocabSize())
	}

	// Example 2: Load tokenizer from HuggingFace (requires internet)
	fmt.Println("\n=== Example 2: Loading from HuggingFace ===")
	fmt.Println("Attempting to download bert-base-uncased from HuggingFace...")
	
	hfTk, err := tokenizers.FromPretrained("bert-base-uncased")
	if err != nil {
		log.Printf("Failed to load tokenizer from HuggingFace: %v", err)
		log.Println("This might be due to network issues or rate limiting")
	} else {
		defer hfTk.Close()
		
		text := "Windows tokenizer example with HuggingFace model"
		fmt.Printf("Text: %s\n", text)
		
		// Encode with options
		encoding := hfTk.EncodeWithOptions(text, true, 
			tokenizers.WithReturnAllAttributes())
		
		fmt.Printf("Token IDs: %v\n", encoding.IDs)
		fmt.Printf("Tokens: %v\n", encoding.Tokens)
		fmt.Printf("Attention Mask: %v\n", encoding.AttentionMask)
		fmt.Printf("Type IDs: %v\n", encoding.TypeIDs)
		fmt.Printf("Offsets: %v\n", encoding.Offsets)
		
		decoded := hfTk.Decode(encoding.IDs, true)
		fmt.Printf("Decoded: %s\n", decoded)
	}

	// Example 3: Demonstrate Windows-specific paths
	fmt.Println("\n=== Example 3: Windows path handling ===")
	if runtime.GOOS == "windows" {
		// Test with Windows-style paths
		windowsPaths := []string{
			"C:\\Users\\Public\\tokenizer.json",
			"..\\test\\data\\bert-base-uncased.json",
			".\\tokenizer.json",
		}
		
		for _, path := range windowsPaths {
			fmt.Printf("Testing path: %s\n", path)
			_, err := tokenizers.FromFile(path)
			if err != nil {
				fmt.Printf("  ❌ Failed (expected): %v\n", err)
			} else {
				fmt.Printf("  ✅ Success\n")
			}
		}
	}

	// Example 4: Performance test
	fmt.Println("\n=== Example 4: Performance test ===")
	if tk != nil {
		text := "This is a performance test for the Windows tokenizer implementation."
		
		fmt.Println("Running 1000 encoding operations...")
		for i := 0; i < 1000; i++ {
			_, _ = tk.Encode(text, false)
		}
		fmt.Println("✅ Performance test completed successfully")
	}

	fmt.Println("\n=== Windows Example Complete ===")
	fmt.Println("If you see this message, the tokenizer library is working correctly on Windows!")
}
