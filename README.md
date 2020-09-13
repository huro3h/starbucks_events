### starbucks_events is 何?  
SlackのChannelで任意の単語をフックにして  
特定店舗のイベント一覧を雑に取得してChannelに結果を返す  
ServerlessでChatOps的なやつ  
  
AWS LambdaのGUI操作だけでRubyでやろうと思ったら  
入れたnativeなgemが動かないやら何だかよくわからないわ状態...🤷‍♀️  
結局いっぱい調べることに  
  
#### 用意したもの  
- Slack  
  - 投稿用 Workspace & Channel  
  - incoming webhook  
  - outgoing webhook
- AWS  
  - API Gateway
  - Lambda
  - S3
  - IAM  
  - (CloudFormation)
- ローカル側(mac)

#### 環境設定(mac)  
- aws-sam
  - Rubyでnativeなgem使うのにそのままのLambda上では動かないらしいので  
  - ローカルのDockerコンテナ内でgemのインストールから、実行環境から  
  よしなにやってくれるServerlessFramework
- pyenv  
- aws-samを入れるまでの経由管理ツール
brew -> pyenv -> aws-sam

#### ローカルでのビルド ~ deploy
##### ファイル内容書き換えたら毎回buildする  
ビルドにめっちゃ時間かかるようになってる。2,3分くらい  
(--use-container のハイフンの数に注意、間違えると bundlerがエラー何とか言われる)  
  
`$ sam build --use-container`  
  
  
```
$ sam build --use-container
Starting Build inside a container
Building resource 'HelloWorldFunction'

Fetching lambci/lambda:build-ruby2.5 Docker container image......
Mounting /Users/satoshiii/myProjects/starbucks_events/hello_world as /tmp/samcli/source:ro,delegated inside runtime container

Build Succeeded

Built Artifacts  : .aws-sam/build
Built Template   : .aws-sam/build/template.yaml

Commands you can use next
=========================
[*] Invoke Function: sam local invoke
[*] Deploy: sam deploy --guided

Running RubyBundlerBuilder:CopySource
Running RubyBundlerBuilder:RubyBundle
Running RubyBundlerBuilder:RubyBundleDeployment
```
  
##### ローカルでビルドしたコンテナ環境内でlambda関数実行  
`sam local invoke HelloWorldFunction --event (file_path/event.json)`  
→ `sam local invoke HelloWorldFunction --event ./events/event.json`  
  
##### パッケージ化  
`$ sam package --s3-bucket (bucket名) --output-template-file packaged.yaml`  

```
$ sam package --s3-bucket huro3h2020-lambda-function --output-template-file packaged.yaml
Uploading to 19681ba653b5f135a9e9bf2e3007eb67  21408764 / 21408764.0  (100.00%)

Successfully packaged artifacts and wrote output template to file packaged.yaml.
Execute the following command to deploy the packaged template
sam deploy --template-file /Users/satoshiii/myProjects/starbucks_events/packaged.yaml --stack-name <YOUR STACK NAME>
```


##### 作ったLambda関数をデプロイ  
(sam-cliのバージョンあげたらコマンド変わってた)  
- 初回だけ `--guided` オプションが必要  
  - 対話式でいろいろ聞かれた後、 `samconfig.toml` (config)ファイルが作られる
  - 2回目からのデプロイはコンフィグファイルから設定読むので `--guided` なしでも大丈夫


~`aws cloudformation deploy --template-file /Users/satoshiii/myProjects/starbucks_events/packaged.yaml --stack-name huro3h-sample --capabilities CAPABILITY_IAM`~  
  
`sam deploy --guided --template-file /your/file/path/to/packaged.yaml --stack-name your-stack-name --capabilities CAPABILITY_IAM`  
-> `sam deploy --guided --template-file /Users/satoshiii/myProjects/starbucks_events/packaged.yaml --stack-name huro3h2020-20190214 --capabilities CAPABILITY_IAM`
  
##### 生成された samconfig.tomlについて  
- git管理していいのかわからん
  - stack_name, s3_bucket名, regionとか平文で書いてある
- 今のところ上げずに手元で管理

  
##### WIP: AWS側での操作  
CloudFormationでできたAPI Gatewayを一旦削除し、  
postメソッドを設定する必要がある  
  
メソッド設定の際、Slackからのメッセージを以下のコードで  


参考:  
AWS LambdaでNokogiriを動かす - Qiita  
https://qiita.com/Y_uuu/items/85c86df8773f7c225521  
  
AWS SAMでLambda関数を作成 - わくわくBank  
https://www.wakuwakubank.com/posts/640-aws-sam/  
  
Macで1からPythonの環境構築をしていく - Qiita  
https://qiita.com/f_kazqi/items/217c55f02d32f845c7cf  
  
あと思い出したらなんか書く 🙃  
  
# starbucks_events

This project contains source code and supporting files for a serverless application that you can deploy with the SAM CLI. It includes the following files and folders.

- hello_world - Code for the application's Lambda function.
- events - Invocation events that you can use to invoke the function.
- tests - Unit tests for the application code. 
- template.yaml - A template that defines the application's AWS resources.

The application uses several AWS resources, including Lambda functions and an API Gateway API. These resources are defined in the `template.yaml` file in this project. You can update the template to add AWS resources through the same deployment process that updates your application code.

If you prefer to use an integrated development environment (IDE) to build and test your application, you can use the AWS Toolkit.  
The AWS Toolkit is an open source plug-in for popular IDEs that uses the SAM CLI to build and deploy serverless applications on AWS. The AWS Toolkit also adds a simplified step-through debugging experience for Lambda function code. See the following links to get started.

* [PyCharm](https://docs.aws.amazon.com/toolkit-for-jetbrains/latest/userguide/welcome.html)
* [IntelliJ](https://docs.aws.amazon.com/toolkit-for-jetbrains/latest/userguide/welcome.html)
* [VS Code](https://docs.aws.amazon.com/toolkit-for-vscode/latest/userguide/welcome.html)
* [Visual Studio](https://docs.aws.amazon.com/toolkit-for-visual-studio/latest/user-guide/welcome.html)

## Deploy the sample application

The Serverless Application Model Command Line Interface (SAM CLI) is an extension of the AWS CLI that adds functionality for building and testing Lambda applications. It uses Docker to run your functions in an Amazon Linux environment that matches Lambda. It can also emulate your application's build environment and API.

To use the SAM CLI, you need the following tools.

* SAM CLI - [Install the SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html)
* Ruby - [Install Ruby 2.5](https://www.ruby-lang.org/en/documentation/installation/)
* Docker - [Install Docker community edition](https://hub.docker.com/search/?type=edition&offering=community)

To build and deploy your application for the first time, run the following in your shell:

```bash
sam build
sam deploy --guided
```

The first command will build the source of your application. The second command will package and deploy your application to AWS, with a series of prompts:

* **Stack Name**: The name of the stack to deploy to CloudFormation. This should be unique to your account and region, and a good starting point would be something matching your project name.
* **AWS Region**: The AWS region you want to deploy your app to.
* **Confirm changes before deploy**: If set to yes, any change sets will be shown to you before execution for manual review. If set to no, the AWS SAM CLI will automatically deploy application changes.
* **Allow SAM CLI IAM role creation**: Many AWS SAM templates, including this example, create AWS IAM roles required for the AWS Lambda function(s) included to access AWS services. By default, these are scoped down to minimum required permissions. To deploy an AWS CloudFormation stack which creates or modified IAM roles, the `CAPABILITY_IAM` value for `capabilities` must be provided. If permission isn't provided through this prompt, to deploy this example you must explicitly pass `--capabilities CAPABILITY_IAM` to the `sam deploy` command.
* **Save arguments to samconfig.toml**: If set to yes, your choices will be saved to a configuration file inside the project, so that in the future you can just re-run `sam deploy` without parameters to deploy changes to your application.

You can find your API Gateway Endpoint URL in the output values displayed after deployment.

## Use the SAM CLI to build and test locally

Build your application with the `sam build` command.

```bash
starbucks_events$ sam build
```

The SAM CLI installs dependencies defined in `hello_world/Gemfile`, creates a deployment package, and saves it in the `.aws-sam/build` folder.

Test a single function by invoking it directly with a test event. An event is a JSON document that represents the input that the function receives from the event source. Test events are included in the `events` folder in this project.

Run functions locally and invoke them with the `sam local invoke` command.

```bash
starbucks_events$ sam local invoke HelloWorldFunction --event events/event.json
```

The SAM CLI can also emulate your application's API. Use the `sam local start-api` to run the API locally on port 3000.

```bash
starbucks_events$ sam local start-api
starbucks_events$ curl http://localhost:3000/
```

The SAM CLI reads the application template to determine the API's routes and the functions that they invoke. The `Events` property on each function's definition includes the route and method for each path.

```yaml
      Events:
        HelloWorld:
          Type: Api
          Properties:
            Path: /hello
            Method: get
```

## Add a resource to your application
The application template uses AWS Serverless Application Model (AWS SAM) to define application resources. AWS SAM is an extension of AWS CloudFormation with a simpler syntax for configuring common serverless application resources such as functions, triggers, and APIs. For resources not included in [the SAM specification](https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md), you can use standard [AWS CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html) resource types.

## Fetch, tail, and filter Lambda function logs

To simplify troubleshooting, SAM CLI has a command called `sam logs`. `sam logs` lets you fetch logs generated by your deployed Lambda function from the command line. In addition to printing the logs on the terminal, this command has several nifty features to help you quickly find the bug.

`NOTE`: This command works for all AWS Lambda functions; not just the ones you deploy using SAM.

```bash
starbucks_events$ sam logs -n HelloWorldFunction --stack-name starbucks_events --tail
```

You can find more information and examples about filtering Lambda function logs in the [SAM CLI Documentation](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-logging.html).

## Unit tests

Tests are defined in the `tests` folder in this project.

```bash
starbucks_events$ ruby tests/unit/test_handler.rb
```

## Cleanup

To delete the sample application that you created, use the AWS CLI. Assuming you used your project name for the stack name, you can run the following:

```bash
aws cloudformation delete-stack --stack-name starbucks_events
```

## Resources

See the [AWS SAM developer guide](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/what-is-sam.html) for an introduction to SAM specification, the SAM CLI, and serverless application concepts.

Next, you can use AWS Serverless Application Repository to deploy ready to use Apps that go beyond hello world samples and learn how authors developed their applications: [AWS Serverless Application Repository main page](https://aws.amazon.com/serverless/serverlessrepo/)

