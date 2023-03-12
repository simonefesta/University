package main

import (
	"fmt"
)

func main() {
	var p1 *int

	i := 1
	p1 = &i          // p1, of type *int, points to i
	fmt.Println(*p1) // "1”
	*p1 = 2          // equivalent to i = 2
	fmt.Println(i)   // "2"

	var p2 = f()
	fmt.Println(*p2)
}

func f() *int {
	v := 10
	return &v
}
