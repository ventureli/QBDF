# QBDF

frameworkTestcase  文件夹是一个对打包成.framework 的QBDFLanguage 测试的工程。
QBDFLanguage/QBDFLanguage.xcodeproj 是framework 主工程，用于打包framework
QBDFLanguage/QBDFScript 是所有的源码
QBDFLanguage/TestQBDFScript 相当于Example 工程，可以用于开发源码，而后用QBDFLanguage.xcodeproj 进行SDK打包。暂时没做pods，大家有需要可以自己重新混淆后打包，所有人用一个SDK，风险太大。
经过测试，混淆后appstore是检测不出来的。

languagepack.sh 这是一个打包脚本，用于给模拟器和真机器的framework 合并成一个；
