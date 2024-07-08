import mongoose from 'mongoose';
import Order from '../models/orderModel.js';
export async function getSalesPerformance(req, res) {
    const storeId = req.store?.storeId;
    const { startDate, endDate } = req.query;

    if (!mongoose.Types.ObjectId.isValid(storeId)) {
        return res.status(400).json({ msg: 'Invalid store ID' });
    }

    if (!startDate || !endDate) {
        return res.status(400).json({ msg: 'Start date and end date are required' });
    }

    const start = new Date(startDate).setHours(0, 0, 0, 0);
    const end = new Date(endDate).setHours(23, 59, 59, 999);

    try {
        const result = await Order.aggregate([
            { 
                $match: {
                    store: new mongoose.Types.ObjectId(storeId),
                    status: 'delivered',
                    createdAt: {
                        $gte: new Date(start),
                        $lte: new Date(end)
                    }
                } 
            },
            {
                $group: {
                    _id: {
                        date: { $dateToString: { format: "%Y-%m-%d", date: "$createdAt" } },
                        dayOfWeek: { $dayOfWeek: "$createdAt" }
                    },
                    totalSales: { $sum: "$total" },
                    count: { $sum: 1 }
                }
            },
            { $sort: { "_id.date": 1 } },
            {
                $project: {
                    date: "$_id.date",
                    dayOfWeek: "$_id.dayOfWeek",
                    totalSales: 1,
                    count: 1,
                    _id: 0
                }
            }
        ]);

        const salesData = result.map(item => ({
            date: item.date,
            dayOfWeek: item.dayOfWeek,
            totalSales: item.totalSales,
            count: item.count
        }));

        res.status(200).json({
            status: "success",
            message: `Sales performance data from ${new Date(start).toLocaleDateString()} to ${new Date(end).toLocaleDateString()} for store ID: ${storeId} retrieved successfully.`,
            salesData,
        });
    } catch (error) {
        res.status(500).json({
            status: "error",
            message: `Failed to get sales performance data for store ID: ${storeId}: ${error.message}`,
        });
        console.error(error);
        throw error;
    }
}


export async function getYearlySalesPerformance(req, res) {
    const storeId = req.store?.storeId;
    if (!mongoose.Types.ObjectId.isValid(storeId)) {
        return res.status(400).json({ msg: 'Invalid store ID' });
    }

    // Calculate the start and end dates of the current year
    const currentYear = new Date().getFullYear();
    const firstDayOfYear = new Date(currentYear, 0, 1); // January 1st of current year
    const lastDayOfYear = new Date(currentYear, 11, 31, 23, 59, 59, 999); // December 31st of current year

    try {
        const result = await Order.aggregate([
            { 
                $match: {
                    store: new mongoose.Types.ObjectId(storeId),
                    status: 'delivered',
                    createdAt: {
                        $gte: firstDayOfYear,
                        $lte: lastDayOfYear
                    }
                } 
            },
            {
                $group: {
                    _id: {
                        month: { $month: "$createdAt" }, // Group by month
                        year: { $year: "$createdAt" }  // Include year to ensure data is for the correct year
                    },
                    totalSales: { $sum: "$total" },
                    count: { $sum: 1 }
                }
            },
            { $sort: { "_id.month": 1 } }, // Sort by month
            {
                $project: {
                    month: "$_id.month",
                    year: "$_id.year",
                    totalSales: 1,
                    count: 1,
                    _id: 0
                }
            }
        ]);

        const salesData = result.map(item => ({
            month: item.month,
            year: item.year,
            totalSales: item.totalSales,
            count: item.count
        }));

        res.status(200).json({
            status: "success",
            message: `Yearly sales performance data for ${currentYear} for store ID: ${storeId} retrieved successfully.`,
            salesData,
        });
    } catch (error) {
        res.status(500).json({
            status: "error",
            message: `Failed to get yearly sales performance data for store ID: ${storeId}: ${error.message}`,
        });
        console.error(error);
        throw error;
    }
}

export async function getbarYearlySalesPerformance(req, res) {
    const storeId = req.store?.storeId;
  
    if (!mongoose.Types.ObjectId.isValid(storeId)) {
      return res.status(400).json({ msg: 'Invalid store ID' });
    }
  
    const currentYear = new Date().getFullYear();
    const start = new Date(currentYear, 0, 1); // January 1st
    const end = new Date(currentYear, 11, 31, 23, 59, 59, 999); // December 31st
  
    try {
        const salesData = await Order.aggregate([
            {
                $match: {
                    store: new mongoose.Types.ObjectId(storeId), // Correct usage
                    status: 'delivered',
                    createdAt: {$gte: start, $lte: end}
                }
            },
            {
                $group: {
                    _id: { month: {$month: "$createdAt"} },
                    totalSales: {$sum: "$total"},
                    count: {$sum: 1}
                }
            },
            {
                $project: {
                    _id: 0,
                    month: "$_id.month",
                    totalSales: 1,
                    count: 1
                }
            },
            {$sort: {month: 1}}
        ]);
    
        // Convert month numbers to month names using server-side logic or during data presentation in client
        const formattedData = salesData.map(data => ({
            ...data,
            month: new Date(0, data.month - 1).toLocaleString('en-us', {month: 'short'})
        }));
    
        res.status(200).json({
            status: "success",
            message: "Yearly sales performance data retrieved successfully.",
            salesData: formattedData
        });
    } catch (error) {
        console.error("Failed to fetch yearly sales performance data:", error);
        res.status(500).json({
            status: "error",
            message: `Error fetching data: ${error.message}`,
        });
    }
}