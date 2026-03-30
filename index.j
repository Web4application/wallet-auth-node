const express = require('express');
const cors = require('cors');
const { ethers } = require('ethers');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});        

app.post('/verify-signature', async (req, res) => {
  const { message, signature, walletAddress } = req.body;

  try {
    // Recover the signer from the signed message
    const recoveredAddress = ethers.utils.verifyMessage(message, signature);

    // Check if the recovered address matches the wallet address
    if (recoveredAddress.toLowerCase() === walletAddress.toLowerCase()) {
      return res.json({ success: true, message: 'Signature verified!' });
    } else {
      return res.status(401).json({ success: false, message: 'Invalid signature' });
    }
  } catch (error) {
    console.error('Error verifying signature:', error);
    return res.status(500).json({ success: false, message: 'Verification failed' });
  }
});        

app.get('/get-nonce/:walletAddress', (req, res) => {
  const walletAddress = req.params.walletAddress.toLowerCase();

  // Create a random nonce
  const nonce = `Login request at ${Date.now()}`;

  // Store it
  nonces[walletAddress] = nonce;

  res.json({ nonce });
});    

app.post('/verify-signature', (req, res) => {
  const { message, signature, walletAddress } = req.body;
  const savedNonce = nonces[walletAddress.toLowerCase()];

  if (!savedNonce || savedNonce !== message) {
    return res.status(400).json({ success: false, message: 'Invalid or expired nonce' });
  }

  try {
    const recovered = ethers.utils.verifyMessage(message, signature);
    if (recovered.toLowerCase() === walletAddress.toLowerCase()) {
      // Optional: delete nonce after use
      delete nonces[walletAddress.toLowerCase()];
      return res.json({ success: true, message: 'Wallet authenticated!' });
    } else {
      return res.status(401).json({ success: false, message: 'Signature mismatch' });
    }
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Verification failed' });
  }
});        
