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

type Sales struct {
	MarketFlow        string `json:"marketFlow"`
	PreSale           string `json:"preSale"`
	Distributors      string `json:"distributors"`
	Retailers         string `json:"retailers"`
	PurchaseTime      string `json:"purchaseTime"`
	ShelfTime         string `json:"shelfTime"`
	StorageConditions string `json:"storageConditions"`
}

type QueryResult struct {
	Key    string `json:"Key"`
	Record *Sales
}

func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	transportation := []Sales{
		Sales{"海外", "true", "兰州饿了有限公司", "兰州不饿有限公司", "2022.3.4", "2022.5.6", "-6"},
	}
	for i, item := range transportation {
		itemAsBytes, _ := json.Marshal(item)
		err := ctx.GetStub().PutState("Sales"+strconv.Itoa(i), itemAsBytes)

		if err != nil {
			return fmt.Errorf("Failed to put to world state. %s", err.Error())
		}
	}

	return nil
}

// CreateFarm adds a new farm to the world state with given details
func (s *SmartContract) CreateFarm(ctx contractapi.TransactionContextInterface, salesNumber string,
	marketFlow string, preSale string, distributors string,
	retailers string, purchaseTime string, shelfTime string, storageConditions string) error {
	sales := Sales{
		MarketFlow:        marketFlow,
		PreSale:           preSale,
		Distributors:      distributors,
		Retailers:         retailers,
		PurchaseTime:      purchaseTime,
		ShelfTime:         shelfTime,
		StorageConditions: storageConditions,
	}

	itemAsBytes, _ := json.Marshal(sales)

	return ctx.GetStub().PutState(salesNumber, itemAsBytes)
}

// QueryFarm returns the car stored in the world state with given id
func (s *SmartContract) QueryFarm(ctx contractapi.TransactionContextInterface, storageNumber string) (*Sales, error) {
	itemAsBytes, err := ctx.GetStub().GetState(storageNumber)

	if err != nil {
		return nil, fmt.Errorf("failed to read sales world state. %s", err.Error())
	}

	if itemAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", storageNumber)
	}

	sales := new(Sales)
	_ = json.Unmarshal(itemAsBytes, sales)

	return sales, nil
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

		sales := new(Sales)
		_ = json.Unmarshal(queryResponse.Value, sales)

		queryResult := QueryResult{Key: queryResponse.Key, Record: sales}
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
		fmt.Printf("Error create sales chaincode: %s", err.Error())
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting sales chaincode: %s", err.Error())
	}
}
