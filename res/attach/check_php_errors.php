<?php

// 定期检测指定日志文件有没有新内容产生

const FT_SEND_KEY = '434-6f8b1b7dd2885617ff92fc992146f6b0';
const SERVER_NAME = 'Silverd-No.2';

// 以下开始无需修改

// 源文件
$sourceFile = '/home/wwwlogs/php_errors.log';
$copyFile = $sourceFile . '.copy';

// 差异内容
$diffContent = '';

if (! file_exists($sourceFile)) {
    touch($sourceFile);
    exit('日志源文件内容为空');
}

// 不存在，则创建一个新的文件
if (! file_exists($copyFile)) {
    touch($copyFile);
}

$diffContent = shell_exec('diff ' . $sourceFile . ' ' . $copyFile);

// 将源文件复制
copy($sourceFile, $copyFile);

// 没有差异
if (! $diffContent) {
    exit('没有新产生的差异内容');
}

$subject = basename($sourceFile) . '@' . SERVER_NAME . '有新内容产生';

file_get_content('https://pushbear.ftqq.com/sub?sendkey=' . FT_SEND_KEY
    . '&text=' . $subject
    . '&desp=' . $diffContent);
