import Store from '../models/storeModel.js';

export async function getUnverifiedStoresWithLicenseImage(req, res) {
    try {
        const stores = await Store.find({ verified: false, licenseImage: { $exists: true, $ne: null } });
        
        if (stores.length === 0) {
            return res.status(404).json({ status: 'error', message: 'No unverified stores with a license image found.' });
        }

        return res.status(200).json({
            status: 'success',
            message: 'Unverified stores with a license image retrieved successfully.',
            stores: stores
        });
    } catch (error) {
        return res.status(500).json({ status: 'error', message: `An error occurred while retrieving stores: ${error.message}` });
    }
}