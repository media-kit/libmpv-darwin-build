#include <stdio.h>
#include <stdlib.h>
#include <libavformat/avio.h>
#include <libavformat/avformat.h>
#include <libavutil/dict.h>
#include <libavutil/error.h>

static int connect_tls(const char *url, int verify)
{
    AVIOContext *connection = NULL;
    AVDictionary *options = NULL;
    av_dict_set(&options, "tls_verify", verify ? "1" : "0", 0);
    av_dict_set(&options, "rw_timeout", "15000000", 0);
    int result = avio_open2(&connection, url, AVIO_FLAG_READ, NULL, &options);
    av_dict_free(&options);
    avio_closep(&connection);
    return result;
}

int main(int argc, char **argv)
{
    if (argc != 3)
        return 2;
    int expected = atoi(argv[2]);
    avformat_network_init();
    // Establish reachability separately so a DNS/connection failure cannot pass
    // a certificate rejection test. Production always verifies certificates.
    if (!expected && connect_tls(argv[1], 0) < 0) {
        fprintf(stderr, "Endpoint is unreachable: %s\n", argv[1]);
        return 1;
    }
    int result = connect_tls(argv[1], 1);
    if ((result >= 0) != expected) {
        char error[AV_ERROR_MAX_STRING_SIZE];
        av_strerror(result, error, sizeof(error));
        fprintf(stderr, "Unexpected trust result for %s: %s\n", argv[1], error);
        return 1;
    }
    printf("%s: %s\n", argv[1], expected ? "trusted" : "certificate rejected");
    avformat_network_deinit();
    return 0;
}
