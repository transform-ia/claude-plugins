# MinIO Integration Patterns

## Client setup
```go
import "github.com/minio/minio-go/v7"
import "github.com/minio/minio-go/v7/pkg/credentials"

mc, err := minio.New(cfg.MinioEndpoint, &minio.Options{
    Creds:  credentials.NewStaticV4(cfg.MinioAccessKey, cfg.MinioSecretKey, ""),
    Secure: cfg.MinioUseSSL,
})
```

## Object key naming convention
`{org_id}/{year}/{month}/{uuid}.{ext}`

Example: `testorg/2024/01/f47ac10b-58cc-4372-a567-0e02b2c3d479.pdf`

## Upload pattern
```go
_, err = mc.PutObject(ctx, bucket, key, reader, size, minio.PutObjectOptions{
    ContentType: contentType,
})
```

## Presigned GET URL (1 hour expiry)
```go
presignedURL, err := mc.PresignedGetObject(ctx, bucket, key, time.Hour, url.Values{})
```

**NEVER store presigned URLs in the database.** Generate fresh ones per request.

## Download (for worker processing)
```go
obj, err := mc.GetObject(ctx, bucket, key, minio.GetObjectOptions{})
defer obj.Close()
data, err := io.ReadAll(obj)
```

## Port conventions
- MinIO S3 API: **9100** (9000 conflicts with OAuth2 Go server)
- MinIO Web Console: **9101**
