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

type Transportation struct {
	BrandTransport           string `json:"brandTransport"`
	SterilizationCertificate string `json:"sterilizationCertificate"`
	StartingEnding           string `json:"startingEnding"`
	Date                     string `json:"date"`
	Personnel                string `json:"personnel"`
	Quantity                 string `json:"quantity"`
}

type QueryResult struct {
	Key    string `json:"Key"`
	Record *Transportation
}

func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	transportation := []Transportation{
		Transportation{"c3467", "true", "兰州/西安", "1.22/1.28", "王武", "50"},
	}
	for i, item := range transportation {
		itemAsBytes, _ := json.Marshal(item)
		err := ctx.GetStub().PutState("Transportation"+strconv.Itoa(i), itemAsBytes)

		if err != nil {
			return fmt.Errorf("Failed to put to world state. %s", err.Error())
		}
	}

	return nil
}

// CreateFarm adds a new farm to the world state with given details
func (s *SmartContract) CreateFarm(ctx contractapi.TransactionContextInterface, transportationNumber string,
	brandTransport string, sterilizationCertificate string, startingEnding string,
	date string, personnel string, quantity string) error {
	transportation := Transportation{
		BrandTransport:           brandTransport,
		SterilizationCertificate: sterilizationCertificate,
		StartingEnding:           startingEnding,
		Date:                     date,
		Personnel:                personnel,
		Quantity:                 quantity,
	}

	itemAsBytes, _ := json.Marshal(transportation)

	return ctx.GetStub().PutState(transportationNumber, itemAsBytes)
}

// QueryFarm returns the car stored in the world state with given id
func (s *SmartContract) QueryFarm(ctx contractapi.TransactionContextInterface, storageNumber string) (*Transportation, error) {
	itemAsBytes, err := ctx.GetStub().GetState(storageNumber)

	if err != nil {
		return nil, fmt.Errorf("failed to read transportation world state. %s", err.Error())
	}

	if itemAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", storageNumber)
	}

	transportation := new(Transportation)
	_ = json.Unmarshal(itemAsBytes, transportation)

	return transportation, nil
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

		transportation := new(Transportation)
		_ = json.Unmarshal(queryResponse.Value, transportation)

		queryResult := QueryResult{Key: queryResponse.Key, Record: transportation}
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
		fmt.Printf("Error create transportation chaincode: %s", err.Error())
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting transportation chaincode: %s", err.Error())
	}
}
