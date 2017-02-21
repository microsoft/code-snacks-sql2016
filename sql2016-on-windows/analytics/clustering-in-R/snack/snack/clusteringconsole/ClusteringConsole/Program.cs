using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClusteringConsole
{
    class Program
    {
        static string _connectionString;

        static void Main(string[] args)
        {
            _connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["SqlConnection"].ConnectionString;

            Console.WriteLine("Clustering Taxi Rides...");
            Console.WriteLine();

            ClusterTaxiRides();

        }

        private static void ClusterTaxiRides()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(_connectionString))
                {
                    conn.Open();

                    // Execute the stored procedure
                    using (SqlCommand cmd = new SqlCommand("ClusterTaxiData", conn))
                    {
                        cmd.CommandType = System.Data.CommandType.StoredProcedure;
                        var reader = cmd.ExecuteReader();

                        Console.ForegroundColor = ConsoleColor.Cyan;
                        Console.WriteLine("Passengers\tDistance");
                        while (reader.Read())
                        {
                            Console.WriteLine("{0}\t{1}", reader.GetSqlSingle(0), reader.GetSqlSingle(1));
                        }
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
