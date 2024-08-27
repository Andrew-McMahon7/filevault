const { describe, it, beforeEach, afterEach } = require('mocha');

describe('File API', () => {
    let chai, chaiHttp, sinon, app, db, S3Client, assert;

    before(async () => {
        chai = await import('chai');
        chaiHttp = await import('chai-http/index.js');
        sinon = await import('sinon');
        app = (await import('../index.js')).default;
        db = (await import('../db.js')).default;
        ({ S3Client } = await import('@aws-sdk/client-s3'));
        assert = require('assert');

        chai.use(chaiHttp);
    });

    let s3Stub, dbStub;

    beforeEach(() => {
        s3Stub = sinon.stub(S3Client.prototype, 'send');
        dbStub = sinon.stub(db, 'query');
    });

    afterEach(() => {
        sinon.restore();
    });

    describe('POST /upload', () => {
        it('should upload a file and insert into the database', async () => {
            const fileName = 'example.txt';
            const fileKey = 'example-key';

            s3Stub.resolves();
            dbStub.resolves();

            const res = await chai.request(app)
                .post('/upload')
                .field('note', fileName)
                .attach('file', Buffer.from('file content'), fileKey);

            expect(res).to.have.status(200);
            expect(res.text).to.equal('File uploaded successfully.');
            expect(s3Stub.calledOnce).to.be.true;
            expect(dbStub.calledOnce).to.be.true;
            expect(dbStub.calledWith('INSERT INTO filesData (name, key) VALUES ($1, $2)', [fileName, fileKey])).to.be.true;
        });

        it('should return 400 if no file is uploaded', async () => {
            const res = await chai.request(app)
                .post('/upload')
                .field('note', 'example.txt');

            expect(res).to.have.status(400);
            expect(res.text).to.equal('No file uploaded.');
        });
    });

    describe('DELETE /files/:key', () => {
        it('should delete a file and remove from the database', async () => {
            const fileKey = 'example-key';

            s3Stub.resolves();
            dbStub.resolves();

            const res = await chai.request(app)
                .delete(`/files/${fileKey}`);

            expect(res).to.have.status(200);
            expect(res.text).to.equal('File deleted successfully.');
            expect(s3Stub.calledOnce).to.be.true;
            expect(dbStub.calledOnce).to.be.true;
            expect(dbStub.calledWith('DELETE FROM filesData WHERE key = $1', [fileKey])).to.be.true;
        });

        it('should return 500 if deletion fails', async () => {
            const fileKey = 'example-key';

            s3Stub.rejects(new Error('S3 error'));
            dbStub.resolves();

            const res = await chai.request(app)
                .delete(`/files/${fileKey}`);

            expect(res).to.have.status(500);
            expect(res.text).to.equal('Failed to delete file.');
        });
    });

    describe('GET /files', () => {
        it('should return a list of files', async () => {
            const filesData = [{ name: 'example.txt', key: 'example-key' }];
            dbStub.resolves({ rows: filesData });

            const res = await chai.request(app)
                .get('/files');

            expect(res).to.have.status(200);
            expect(res.body).to.deep.equal(filesData);
            expect(dbStub.calledOnce).to.be.true;
            expect(dbStub.calledWith('SELECT * FROM filesData')).to.be.true;
            assert(dbStub.calledOnceWith('SELECT * FROM filesData'));
        });
    });
});