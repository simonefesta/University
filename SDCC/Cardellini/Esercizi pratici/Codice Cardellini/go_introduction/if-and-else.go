package main

import (
	"fmt"
	"math"
)

func pow(x, n, limit float64) float64 {
	if v := math.Pow(x, n); v < limit {
		return v
	} else {
		fmt.Printf("%g >= %g\n", v, limit)
	}
	// can't use v here, though
	return limit
}

func main() {
	fmt.Println(
		pow(3, 2, 10),
		pow(3, 3, 20),
	)
}
