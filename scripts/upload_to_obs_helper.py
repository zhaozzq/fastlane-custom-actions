from obs import ObsClient #pip3 install esdk-obs-python --trusted-host pypi.org
from optparse import OptionParser


def addParser():
    parser = OptionParser()
    parser.add_option("-k", "--access_key_id",
                      default="",
                      help="obs access_key_id",
                      metavar="access_key_id")
    parser.add_option("-s", "--secret_access_key",
                      default="",
                      help="obs secret_access_key",
                      metavar="secret_access_key")
    parser.add_option("-e", "--server",
                      default="",
                      help="obs server endpoint",
                      metavar="server")
    parser.add_option("-b", "--bucket",
                      default="",
                      help="obs bucket",
                      metavar="bucket")
    parser.add_option("-o", "--object_key",
                      default="",
                      help="obs object_key",
                      metavar="object_key")
    parser.add_option("-a", "--ipa_path",
                      default="",
                      help="ipa_path",
                      metavar="ipa_path")
    parser.add_option("-d", "--dsym_object_key",
                      default="",
                      help="obs dsym_object_key",
                      metavar="dsym_object_key")
    parser.add_option("-y", "--dsym_path",
                      default="",
                      help="dsym_path",
                      metavar="dsym_path")
    return parser.parse_args()


def upload():
    (options, args) = addParser()
    # print(f"options: {options} args: {args}")

    # 创建ObsClient实例
    obsClient = ObsClient(  
        access_key_id=options.access_key_id,    
        secret_access_key=options.secret_access_key,    
        server=options.server
    )
    # 上传文件到obs
    try:
        from obs import PutObjectHeader 
        headers = PutObjectHeader() 
        headers.contentType = 'application/zip'


        print("upload dsym begin!")
        res = obsClient.putFile(options.bucket, options.dsym_object_key, options.dsym_path, headers=headers)
        print(f"uploading dsym result: {res}")

        if res.status < 300: 
            print("Upload dsym successful")
        else:
            raise Exception(f"Error: Upload dsym failed: {res.reason}" )


        print("upload ipa begin!")
        result = obsClient.putFile(options.bucket, options.object_key, options.ipa_path, headers=headers)
        print(f"uploading ipa result: {result}")


        if result.status < 300: 
            print("Upload ipa successful")
        else:
            raise Exception(f"Error: Upload ipa failed: {result.reason}" )
        
        obsClient.close()
        return 1
    except:
        import traceback
        print(traceback.format_exc())

        obsClient.close()
        return 0
     
# 入口
if __name__ == "__main__":
# def main():
    print("upload begining!")
    res = upload()
    if not res:
        raise Exception("Error: Upload failed")

