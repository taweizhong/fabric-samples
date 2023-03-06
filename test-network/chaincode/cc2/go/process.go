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

type Process struct {
	SlaughterhouseName      string `json:"slaughterhouseName"`
	EntryQuarantine         string `json:"entryQuarantine"`
	Cleaning                string `json:"cleaning"`
	SlaughteringTime        string `json:"slaughteringTime"`
	Quarantine              string `json:"quarantine"`
	SegmentationInformation string `json:"segmentationInformation"`
}

type QueryResult struct {
	Key    string `json:"Key"`
	Record *Process
}

func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	Process := []Process{
		Process{"Slaughterhouse1", "true", "true", "2022.2.1", "true", "Ketone body"},
	}
	for i, item := range Process {
		itemAsBytes, _ := json.Marshal(item)
		err := ctx.GetStub().PutState("FARM"+strconv.Itoa(i), itemAsBytes)

		if err != nil {
			return fmt.Errorf("Failed to put to world state. %s", err.Error())
		}
	}

	return nil
}

// CreateFarm adds a new farm to the world state with given details
func (s *SmartContract) CreateFarm(ctx contractapi.TransactionContextInterface, processNumber string, slaughterhouseName string, entryQuarantine string, cleaning string,
	slaughteringTime string, quarantine string, segmentationInformation string) error {
	process := Process{
		SlaughterhouseName:      slaughterhouseName,
		EntryQuarantine:         entryQuarantine,
		Cleaning:                cleaning,
		SlaughteringTime:        slaughteringTime,
		Quarantine:              quarantine,
		SegmentationInformation: segmentationInformation,
	}

	itemAsBytes, _ := json.Marshal(process)

	return ctx.GetStub().PutState(processNumber, itemAsBytes)
}

// QueryFarm returns the car stored in the world state with given id
func (s *SmartContract) QueryFarm(ctx contractapi.TransactionContextInterface, processNumber string) (*Process, error) {
	itemAsBytes, err := ctx.GetStub().GetState(processNumber)

	if err != nil {
		return nil, fmt.Errorf("failed to read from world state. %s", err.Error())
	}

	if itemAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", processNumber)
	}

	process := new(Process)
	_ = json.Unmarshal(itemAsBytes, process)

	return process, nil
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

		process := new(Process)
		_ = json.Unmarshal(queryResponse.Value, process)

		queryResult := QueryResult{Key: queryResponse.Key, Record: process}
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
