package common

import (
	"crypto/tls"
	"net/http"
	"time"
)

var HttpDownloadClient = &http.Client{
	Transport: &http.Transport{
		MaxIdleConns:        50,
		MaxConnsPerHost:     50,
		MaxIdleConnsPerHost: 50,
		IdleConnTimeout:     30 * time.Second,
		TLSClientConfig: &tls.Config{
			InsecureSkipVerify: false,
		},
	},
}

func SetHttpDownloadClient(do func(c *http.Client)) {
	if do != nil {
		do(HttpDownloadClient)
	}
}
