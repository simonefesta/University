package main

import (
	"context"
	"fmt"

	"github.com/aws/aws-lambda-go/lambda"
)

type MyEvent struct {
	N int `json:"n"`
}

func isPrime(n int) bool {
	if n < 2 {
		return false
	}
	for i := 2; i < n; i++ {

		if n%i == 0 {
			return false
		}
	}
	return true
}

func HandleRequest(ctx context.Context, params MyEvent) (string, error) {
	n := params.N
	result := isPrime(n)
	return fmt.Sprintf("%v", result), nil
}

func main() {
	lambda.Start(HandleRequest)
}
