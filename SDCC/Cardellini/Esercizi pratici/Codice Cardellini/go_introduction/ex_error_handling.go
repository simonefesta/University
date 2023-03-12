//esempio di errori per variabili/package non usati 

package main

import (
	"fmt"
	"strconv"
	//"net"	// error
)

func main() {
	//j := 1 //error 
	i, err := strconv.Atoi("42")
	if err != nil {
		fmt.Printf("couldn't convert: %v\n", err)
	}
	fmt.Println("Converted integer:", i)
}
