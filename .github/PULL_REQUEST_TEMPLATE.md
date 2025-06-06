## WHY
<!-- なぜこの変更をするのか、課題は何か、この変更を行った理由を記述 -->

## WHAT
<!-- このPRで何ができる or できないようになるのかの概要を記述 -->

## 確認方法
<!-- このPRの動作確認として何を確認すべきかを記述 -->

## :warning: 影響範囲
<!--- このPRが影響する範囲を箇条書きで列挙していく-->

## LINKS
<!--- JIRAなどの関連リンクを箇条書きで列挙していく -->

## 備考
<!-- いろいろ書いてよい。-->

## 反映作業
terraform apply を自動化するための PR コメントの形式を記載します

PR のコメント内にて、`/apply` の形式で PR コメントを書き込むと GitHub Actions のワークフローで terraform apply が実行されるようになっています。
PR が Approve されていないとワークフローがスキップされるので注意して下さい。

※ PR の概要に上記のコマンドを書き込んでも GitHub Actions のワークフローは実行されないので、PR の概要から上記のコマンドの記載を削除する必要はありません。

`/apply` が成功すると以下のようになります。
<details>
<summary>terraform apply の実行結果</summary>

![例：terraform apply の実行結果](terraform-apply-image.png)

</details>
