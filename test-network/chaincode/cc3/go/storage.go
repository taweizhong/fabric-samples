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

type Storage struct {
	WarehouseLocation       string `json:"warehouseLocation"`
	StorageDate             string `json:"storageDate"`
	Facilities              string `json:"facilities"`
	IoQuantity              string `json:"ioQuantity"`
	IoTime                  string `json:"ioTime"`
	StorageTemperature      string `json:"storageTemperature"`
	EnvironmentalConditions string `json:"environmentalConditions"`
}

type QueryResult struct {
	Key    string `json:"Key"`
	Record *Storage
}

func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	storage := []Storage{
		Storage{"兰州01街", "2022.2.1", "冰柜", "12/8", "2022.1.1", "-3", "2RH"},
	}
	for i, item := range storage {
		itemAsBytes, _ := json.Marshal(item)
		err := ctx.GetStub().PutState("Storage"+strconv.Itoa(i), itemAsBytes)

		if err != nil {
			return fmt.Errorf("Failed to put to world state. %s", err.Error())
		}
	}

	return nil
}

// CreateFarm adds a new farm to the world state with given details
func (s *SmartContract) CreateFarm(ctx contractapi.TransactionContextInterface, storageNumber string, warehouseLocation string, storageDate string, facilities string,
	ioQuantity string, ioTime string, storageTemperature string, environmentalConditions string) error {
	storage := Storage{
		WarehouseLocation:       warehouseLocation,
		StorageDate:             storageDate,
		Facilities:              facilities,
		IoQuantity:              ioQuantity,
		IoTime:                  ioTime,
		StorageTemperature:      storageTemperature,
		EnvironmentalConditions: environmentalConditions,
	}

	itemAsBytes, _ := json.Marshal(storage)

	return ctx.GetStub().PutState(storageNumber, itemAsBytes)
}

// QueryFarm returns the car stored in the world state with given id
func (s *SmartContract) QueryFarm(ctx contractapi.TransactionContextInterface, storageNumber string) (*Storage, error) {
	itemAsBytes, err := ctx.GetStub().GetState(storageNumber)

	if err != nil {
		return nil, fmt.Errorf("failed to read from world state. %s", err.Error())
	}

	if itemAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", storageNumber)
	}

	storage := new(Storage)
	_ = json.Unmarshal(itemAsBytes, storage)

	return storage, nil
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

		storage := new(Storage)
		_ = json.Unmarshal(queryResponse.Value, storage)

		queryResult := QueryResult{Key: queryResponse.Key, Record: storage}
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
