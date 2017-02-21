var Connection = require('tedious').Connection;
var Request = require('tedious').Request;
var TYPES = require('tedious').TYPES;

// Provide the connection details appropriate to your environment
var config = {
    userName: 'sa',
    password: 'Abc1234567890',
    server: 'localhost',
    options: {
        database: 'adventureworks',
        encrypt: true
    },
    loginID : 'adventure-works\\lynn0'
};

var connection = new Connection(config);

connection.on('connect', function(err) {

    if (err)
    {
        console.log("Unable to Connect: " + err);
        return;
    }
    
    // If no error, then good to go...
    console.log("Connected.");

    executeSetSessionStatement();

});


function executeSetSessionStatement() {
    // Specify the name of the predictive stored procedure
    storedProcedureName = "sp_set_session_context";

    request = new Request(storedProcedureName, function(err, rowCount) {
        if (err) {
            console.log(err);
        } else {
             // Invoke the query in the session context
            executeQuery();
        }
    });

    // The input values to the prediction are provided here:
    request.addParameter('@key', TYPES.VarChar, 'LoginID');
    request.addParameter('@value', TYPES.VarChar, config.loginID);
    request.addParameter('@readonly', TYPES.Int, '1');

    // Iterate over any received rows in the result
    request.on('row', function(columns) {
        console.log("Session login set")
        columns.forEach(function(column) {
            console.log(column.metadata.colName + " = " + column.value);
        });
    });

    connection.callProcedure(request);
}

function executeQuery() {

    // Specify the name of the predictive stored procedure
    sqlQuery = "SELECT Count(*) FROM [HumanResources].[Employee]";

    request = new Request(sqlQuery, function(err, rowCount) {
        if (err) {
            console.log(err);
        } else {
            console.log(rowCount + ' rows');
        }
    });

    // Iterate over any received rows in the result
    request.on('row', function(columns) {
        columns.forEach(function(column) {
        console.log(column.metadata.colName + " = " + column.value);
        });
    });

    console.log("Executing query: " + sqlQuery);

    connection.execSql(request);
}