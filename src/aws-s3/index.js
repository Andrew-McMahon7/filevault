const express = require('express');
const multer = require('multer');
const db = require('./db');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const { S3Client, DeleteObjectCommand } = require('@aws-sdk/client-s3');
const { Upload } = require('@aws-sdk/lib-storage');
const { DynamoDBClient, PutItemCommand, DeleteItemCommand, ScanCommand } = require('@aws-sdk/client-dynamodb');

const app = express();
const PORT = process.env.PORT || 3000;

const upload = multer({ dest: 'uploads/' });

const s3 = new S3Client({
    region: process.env.AWS_REGION,
    credentials: {
        accessKeyId: process.env.BUCKET_AWS_ACCESS_KEY_ID,
        secretAccessKey: process.env.BUCKET_AWS_SECRET_ACCESS_KEY,
    }
});

const dynamoDBClient = new DynamoDBClient({
    region: process.env.AWS_REGION,
    credentials: {
        accessKeyId: process.env.BUCKET_AWS_ACCESS_KEY_ID,
        secretAccessKey: process.env.BUCKET_AWS_SECRET_ACCESS_KEY,
    },
});

const dynamoDBTable = 'DynamoDB-Terraform';

const formatItems = (items) => {
    return items.map(item => {
        return {
            name: item.name.S,
            key: item.key.S
        };
    });
};

const loadFilesData = async () => {
    const params = {
        TableName: dynamoDBTable,
    };

    try {
        console.log("Retrieving all items from the table...");
        const data = await dynamoDBClient.send(new ScanCommand(params));
        console.log('All items retrieved:', formatItems(data.Items));
        return formatItems(data.Items);
    } catch (error) {
        console.error('Error retrieving items:', error);
    }
};

async function putItem(name, key) {
    const params = {
        TableName: dynamoDBTable,
        Item: {
            name: { S: name },
            key: { S: key }
        }
    };

    try {
        await dynamoDBClient.send(new PutItemCommand(params));
        console.log('Item inserted successfully');
    } catch (error) {
        console.error('Error inserting item:', error);
    }
}

async function deleteItem(name, key) {
    const params = {
        TableName: dynamoDBTable,
        Key: {
            name: { S: name },
            key: { S: key }
        }
    };

    try {
        await dynamoDBClient.send(new DeleteItemCommand(params));
        console.log('Item deleted successfully');
    } catch (error) {
        console.error('Error deleting item:', error);
    }
}

let files = loadFilesData();

app.use(express.static(path.join(__dirname, 'public')));
app.use(express.json());

app.post('/upload', upload.single('file'), async (req, res) => {
    const fileName = req.body.note;
    if (!fileName) {
        return res.status(400).send('File name is required.');
    }

    if (req.file) {
        try {
            const fileStream = fs.createReadStream(req.file.path);
            const uploadParams = {
                Bucket: process.env.S3_BUCKET_NAME,
                Key: req.file.filename,
                Body: fileStream,
            };

            const upload = new Upload({
                client: s3,
                params: uploadParams,
            });

            await upload.done();
            fs.unlinkSync(req.file.path); // remove the file locally after upload

            // Insert the file entry into the database
            putItem(fileName, req.file.filename);

            // Reload the files array
            files = loadFilesData();

            res.status(200).send('File uploaded successfully.');
        } catch (err) {
            console.error('Error uploading file:', err);
            res.status(500).send('Failed to upload file.');
        }
    } else {
        res.status(400).send('No file uploaded.');
    }
});

app.get('/files', (req, res) => {
    files.then((files) => {
        res.json(files);
    });
});

app.delete('/files/:key', async (req, res) => {
    const fileKey = req.params.key;
    const { name: fileName } = req.body;

    console.log('Deleting file:', fileName);

    try {
        const deleteParams = {
            Bucket: process.env.S3_BUCKET_NAME,
            Key: fileKey,
        };

        await s3.send(new DeleteObjectCommand(deleteParams));

        // Delete the file entry from the database
        deleteItem(fileName, fileKey);

        // Reload the files array
        files = loadFilesData();

        res.status(200).send('File deleted successfully.');
    } catch (err) {
        console.error('Error deleting file:', err);
        res.status(500).send('Failed to delete file.');
    }
});

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
