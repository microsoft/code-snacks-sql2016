using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;

namespace SqlSecurity
{
    class Program
    {
        static string _connectionString;
        static string _loginID;

        static void Main(string[] args)
        {
            _connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["SqlConnection"].ConnectionString;

            Console.WriteLine("Select which type of user to execute query as:");
            Console.WriteLine(@"1. Contractor (adventure-works\lynn0)");
            Console.WriteLine(@"2. Human Resources (adventure-works\paula0)");
            Console.WriteLine(@"3. Executive (adventure-works\ken0)");

            var result = Console.ReadKey();
            switch (result.KeyChar)
            {
                case '1':
                    _loginID = @"adventure-works\lynn0";
                    break;
                case '2':
                    _loginID = @"adventure-works\paula0";
                    break;
                case '3':
                    _loginID = @"adventure-works\ken0";
                    break;
            }
            Console.WriteLine();

            QueryEmployeeTable();

        }

        private static void QueryEmployeeTable()
        {
            Console.WriteLine("Querying Employee table...");
            try
            {
                using (SqlConnection conn = new SqlConnection(_connectionString))
                {
                    conn.Open();

                    // Set the Session context to include the LoginID
                    using (SqlCommand cmd = new SqlCommand("sp_set_session_context", conn))
                    {
                        cmd.CommandType = System.Data.CommandType.StoredProcedure;
                        List<SqlParameter> parameters = new List<SqlParameter>() {
                        new SqlParameter("@key", "LoginID"),
                        new SqlParameter("@value", _loginID),
                        new SqlParameter("@readonly", 1),
                        };

                        cmd.Parameters.AddRange(parameters.ToArray());
                        cmd.ExecuteNonQuery();

                        Console.ForegroundColor = ConsoleColor.Cyan;
                        Console.WriteLine("Set context to {0}.", _loginID);
                        Console.ResetColor();
                    }

                    // Query the table
                    string commandText = "SELECT Count(*) FROM [HumanResources].[Employee]";
                    Console.WriteLine("Executing query: " + commandText);
                    using (SqlCommand cmd = new SqlCommand(commandText, conn))
                    {
                        cmd.CommandType = System.Data.CommandType.Text;
                        var rowsCounted = cmd.ExecuteScalar();

                        Console.ForegroundColor = ConsoleColor.Cyan;
                        Console.WriteLine("Employee table has {0} rows.", rowsCounted);
                        Console.ResetColor();
                    }

                    conn.Close();
                }
            }
            catch (Exception ex)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine(ex.Message);
                Console.ResetColor();
            }
        }
    }
}
