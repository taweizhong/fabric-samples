package main

import (
	"encoding/json"
	"fmt"
	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"strconv"
)

type SmartContract struct {
	contractapi.Contract
}

type Farm struct {
	FarmName     string `json:"make"`
	Address      string `json:"model"`
	License      string `json:"colour"`
	Owner        string `json:"owner"`
	BreedingTime string `json:"BreedingTime"`
	ReleaseDate  string `json:"ReleaseDate"`
}

type QueryResult struct {
	Key    string `json:"Key"`
	Record *Farm
}

func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	Farms := []Farm{
		Farm{"Farm1", "gansu", "xxx", "zhangsan", "2022.2.1", "2022.10.23"},
	}
	for i, farm := range Farms {
		farmAsBytes, _ := json.Marshal(farm)
		err := ctx.GetStub().PutState("FARM"+strconv.Itoa(i), farmAsBytes)

		if err != nil {
			return fmt.Errorf("Failed to put to world state. %s", err.Error())
		}
	}

	return nil
}

// CreateFarm adds a new farm to the world state with given details
func (s *SmartContract) CreateFarm(ctx contractapi.TransactionContextInterface, farmNumber string, farmName string, address string, license string, owner string, breedingTime string, releaseDate string) error {
	farm := Farm{
		FarmName:     farmName,
		Address:      address,
		License:      license,
		Owner:        owner,
		BreedingTime: breedingTime,
		ReleaseDate:  releaseDate,
	}

	carAsBytes, _ := json.Marshal(farm)

	return ctx.GetStub().PutState(farmNumber, carAsBytes)
}

// QueryFarm returns the car stored in the world state with given id
func (s *SmartContract) QueryFarm(ctx contractapi.TransactionContextInterface, farmNumber string) (*Farm, error) {
	farmAsBytes, err := ctx.GetStub().GetState(farmNumber)

	if err != nil {
		return nil, fmt.Errorf("failed to read from world state. %s", err.Error())
	}

	if farmAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", farmNumber)
	}

	farm := new(Farm)
	_ = json.Unmarshal(farmAsBytes, farm)

	return farm, nil
}

// QueryAllFarms returns all cars found in world state
func (s *SmartContract) QueryAllFarms(ctx contractapi.TransactionContextInterface) ([]QueryResult, error) {
	startKey := ""
	endKey := ""

	resultsIterator, err := ctx.GetStub().GetStateByRange(startKey, endKey)

	if err != nil {
		return nil, err
	}
	defer func(resultsIterator shim.StateQueryIteratorInterface) {
		err := resultsIterator.Close()
		if err != nil {

		}
	}(resultsIterator)

	var results []QueryResult

	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()

		if err != nil {
			return nil, err
		}

		farm := new(Farm)
		_ = json.Unmarshal(queryResponse.Value, farm)

		queryResult := QueryResult{Key: queryResponse.Key, Record: farm}
		results = append(results, queryResult)
	}

	return results, nil
}

// ChangeCarOwner updates the owner field of car with given id in world state
//func (s *SmartContract) ChangeCarOwner(ctx contractapi.TransactionContextInterface, carNumber string, newOwner string) error {
//	car, err := s.QueryCar(ctx, carNumber)
//
//	if err != nil {
//		return err
//	}
//
//	car.Owner = newOwner
//
//	carAsBytes, _ := json.Marshal(car)
//
//	return ctx.GetStub().PutState(carNumber, carAsBytes)
//}

func main() {

	chaincode, err := contractapi.NewChaincode(new(SmartContract))

	if err != nil {
		fmt.Printf("Error create farm chaincode: %s", err.Error())
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting farm chaincode: %s", err.Error())
	}
}
