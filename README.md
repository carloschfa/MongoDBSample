# MongoDB iOS Sample

Sample project using mongoDB Stitch. It's a CRUD application with an simple listener using ChangeStreamSession<T>.
Methods used were:
  watch(matchFilter: Document, delegate: )
  find()
  insertOne()
  updateOne()
  deleteOne()

## Getting Started

Step 1: 

Go to [MongoDB](https://www.mongodb.com/cloud/stitch) and create an account. 
Create an Atlas Service and a Stitch App.

Step 2:
Go to MongoDB.swift and replace these parameters:
```
static let DATABASE = "database_name"
static let OBJECTS_COLLECTION = "collections_name"
static let ATLAS_SERVICE_NAME = "atlas_service_name"
static let STITCH_APP_ID = "stitch_app_id"
```

Before running the project do:
```
pod install
```

### Prerequisites

All you need is Cocoapods and Xcode 11 with at least iOS 12.4.

## Running the tests

In this application i didn't developed any test.


## Built With

* [MongoDB](https://www.mongodb.com/cloud/stitch) - Servless platform from MongoDB


## Authors

* **Carlos Antunes** - *Initial work* - [carloschfa](https://github.com/carloschfa/)

