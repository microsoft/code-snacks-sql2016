using System;
using System.Collections.Generic;
using System.Linq;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Diagnostics;

namespace SqlLoadGenerator
{
    class Program
    {
        static string _connectionString;
        static int _numRowsToInsert = Properties.Settings.Default.Spike_NumRowsToInsert;
        static int _numTaskPerSpike = Properties.Settings.Default.Spike_NumParallelClients;
        static Stopwatch _stopwatch;
        static string _tableName = "DataPointsDiskBased";

        static void Main(string[] args)
        {
            Console.WriteLine("Which table would you like to target for load? (press 1 or 2)");
            Console.WriteLine("1. Disk Based Table");
            Console.WriteLine("2. Memory-Optimized Table");
            if (Console.ReadKey().KeyChar == '1')
            {
                _tableName = "DataPointsDiskBased";
            }
            else
            {
                _tableName = "DataPointsInMem";
            }
            Console.WriteLine("");

            _connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["SqlConnection"].ConnectionString;

            _stopwatch = Stopwatch.StartNew();

            List<Task> tasks = new List<Task>();

            tasks.AddRange(ScheduleLoadSpike(_numTaskPerSpike));

            Task.WaitAll(tasks.ToArray());
            Console.WriteLine("Tasks completed.");

            _stopwatch.Stop();

            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine("{0} hours {1} minutes {2} seconds elapsed.", 
                _stopwatch.Elapsed.Hours, _stopwatch.Elapsed.Minutes, _stopwatch.Elapsed.Seconds);

            Console.ReadLine();
        }

        static Task[] ScheduleLoadSpike(int numTasks)
        {
            Task[] tasks = new Task[numTasks];
            for (int i = 0; i < numTasks; i++)
            {
                tasks[i] = Task.Run(() => GenerateLoadSpike());
            }

            return tasks;
        }

        static int _numTasks = 0;
        static int GenerateLoadSpike()
        {
            Random Rand = new Random();

            int taskID = System.Threading.Interlocked.Increment(ref _numTasks);
            Console.WriteLine("{0}: Preparing load spike...", taskID);

            int numRowsAffected = 0;

            try
            {

                SqlConnection conn = new SqlConnection(_connectionString);

                string commandText = String.Format("INSERT [dbo].[{0}] ([Value], TimestampUtc, DeviceId) " +
                                      "VALUES (@Value, @TimestampUtc, @DeviceId)", _tableName);

                Random r = new Random(1);

                conn.Open();

                for (int i = 0; i < _numRowsToInsert; i++)
                {
                    // if a transient error closed our connection, create a new one and open it
                    if (conn.State == System.Data.ConnectionState.Closed)
                    {
                        Console.ForegroundColor = ConsoleColor.Red;
                        Console.WriteLine("{0}: Re-creating closed connection", taskID);
                        Console.ResetColor();
                        conn = new SqlConnection(_connectionString);
                        conn.Open();
                    }

                    double value = 9999 + 100 * Rand.NextDouble();
                    List<SqlParameter> parameters = new List<SqlParameter>() {
                        new SqlParameter("@Value", value),
                        new SqlParameter("@TimestampUtc", DateTime.UtcNow),
                        new SqlParameter("@DeviceId", taskID)
                    };


                    try
                    {
                        using (SqlCommand cmd = new SqlCommand(commandText, conn))
                        {
                            cmd.CommandType = System.Data.CommandType.Text;
                            cmd.Parameters.AddRange(parameters.ToArray());
                            numRowsAffected += cmd.ExecuteNonQuery();

                        }
                    }
                    catch (SqlException sqlex)
                    {
                        Console.ForegroundColor = ConsoleColor.Green;
                        Console.WriteLine(sqlex.Message);
                        Console.ResetColor();

                        System.Threading.Thread.Sleep(200);
                    }
                    catch (Exception cmdex)
                    {
                        Console.ForegroundColor = ConsoleColor.Blue;
                        Console.WriteLine(cmdex.Message);
                        Console.ResetColor();

                    }

                    if (i % 1000 == 0)
                    {
                        Console.WriteLine("{0}: Inserted {1} new rows so far", taskID, numRowsAffected);
                    }
                }

                conn.Close();
                conn.Dispose();

                Console.WriteLine("{0}: Inserted {1} new rows", taskID, numRowsAffected);
            }
            catch (Exception ex)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine(ex.Message);
                Console.ResetColor();
            }

            Console.WriteLine("{0}: Finished with load spike.", taskID);
            return numRowsAffected;
        }
    }
}
