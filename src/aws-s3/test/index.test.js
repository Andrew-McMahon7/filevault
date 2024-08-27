// test/index.test.js
let chai, chaiHttp, sinon, app, db, S3Client, DeleteObjectCommand, Upload;

(async () => {
    chai = await import('chai');
    chaiHttp = await import('chai-http');
    sinon = await import('sinon');
    app = (await import('../aws-s3/index')).default; // Adjust the path as necessary
    db = (await import('../aws-s3/db')).default;
    S3Client = (await import('@aws-sdk/client-s3')).S3Client;
    DeleteObjectCommand = (await import('@aws-sdk/client-s3')).DeleteObjectCommand;
    Upload = (await import('@aws-sdk/lib-storage')).Upload;

    chai.use(chaiHttp);
    const { expect } = chai;

    describe('File API', () => {
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
            });
        });
    });
})();