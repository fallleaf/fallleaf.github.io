---
title: "色子肖像--Python程序"
date: 2017-12-28T15:49:14+08:00
lastmod: 2023-07-30T15:49:14+08:00
draft: false
keywords: []
description: ""
tags: ["肖像","Python"]
categories: ["技术与实践"]
slug: tech-dice-portrait-python
---

上一篇色子肖像介绍了把图像变成色子点阵图的基本思路，用python语言采用PIL库写了一个程序，后来发现opencv更加简便合适，就采用numpy以及opencv库，进行了优化。
这是我第一次开始用python语言编写稍微复杂些的程序。对于有一定编程经验的人，采用实现一个功能的方式编程能够很快熟悉该语言，是一种很好的学习方式。

以下是我编写的程序以及简单的注释。

由于要对图像进行数值处理，所以采用opencv以及numpy库。首先是加载库，datetime是用于计算程序运行时间，os是用于获得文件路径，sys是用于获得命令行参数，cv2是opencv库，numpy是python的数组库。
```
import datetime
import os
import sys
import cv2
import numpy as np
```
保证程序本身直接执行，而不是被调用，如果直接执行，则调用main()函数。
```
if __name__ == "__main__":
    main()
```
一个python文件就可以看作是一个python的模块，这个python模块（.py文件）有两种使用方式：直接运行使用和作为模块被其他模块调用。 每一个模块都有一个内置属性__name__。而__name__的值取决与python模块（.py文件）的使用方式。如果是直接运行使用，那么这个模块的__name__值就是“main”；如果是作为模块被其他模块调用，那么这个模块（.py文件）的__name__值就是该模块（.py文件）的文件名且不带路径和文件扩展名，如果dice_portrait_cv.py被其他python程序import dice_portrait_cv，则__name__为dice_portrait_cv。 main()函数，主要功能流程的执行，分别是：

1.初始化文件路径
```
def main():
    start_time = datetime.datetime.now() #设置程序运行开始时间
    #初始化文件路径
    EXEC_PATH = os.getcwd()
    DICEPATH = EXEC_PATH + '\\dice_image\\'
    OUTPUTPATH = EXEC_PATH + '\\output\\'
    if not (os.path.exists(OUTPUTPATH)):
       os.mkdir(OUTPUTPATH)
```
2.获得命令行参数，调用自定义函数getvalue()，返回输入图片文件名，色子列数，是否旋转
```
    imagefile, DICE_WIDTH, ROTATE = getvalue()
```
3.读取要渲染的图片及色子图片
```
    im = cv2.imread(imagefile, 0)
    dice = getDice(DICEPATH)
```
4.调用自定义函数，调整图片大小，返回图片数组
```
    im = AjustImage(DICE_WIDTH, im)
```
5.定义灰色度数值对应色子1-6点的分组，用了list，也可以用numpy的数组
```
    p = [60, 80, 110, 150, 190, 220]
    #使用numpy数组
    p = np.array([60, 80, 110, 150, 190, 220])
```
6.对图像进行16x16图块分割，并计算灰度，对应色子1-6，并将图片转换成色子点阵图，调用自定义函数，获得处理后的图像以及色子点数文件。
```
    im, dice_data = calculateDice(im, imagefile, p, dice, ROTATE)
```
7.保存图片及色子点数文件
```
    write_Dice(im, OUTPUTPATH, imagefile, dice_data)
```
8.打印运行时间以及色子图片，按任意键退出
```
    end_time = datetime.datetime.now()
    print('程序运行时间:', end_time - start_time,'秒')
    cv2.imshow(imagefile, im)
    cv2.waitKey(0)
```
下面是自定义函数。 1.获得命令行变量，返回变量：imagefile（输入文件名）, DICE_WIDTH（色子列数）, ROTATE（色子2，3，6是否旋转） def getvalue():
```
    if (len(sys.argv) < 2 or len(sys.argv) > 4):
        print("Error, invalid arguments!")
        print("Call with " + sys.argv[0] + " inputimage [tile-size] ")
        sys.exit(1)
    ROTATE = False
    DICE_WIDTH = 50
    if len(sys.argv) == 2:
        imagefile = sys.argv[1]
    elif len(sys.argv) == 3:
        imagefile = sys.argv[1]
        DICE_WIDTH = int(sys.argv[2])
        if (DICE_WIDTH > 150 or DICE_WIDTH < 30):
            print("色子列数不正确，应在30-150之间")
            sys.exit(1)
    else:
        imagefile = sys.argv[1]
        DICE_WIDTH = int(sys.argv[2])
        if (DICE_WIDTH > 150 or DICE_WIDTH < 30):
            print("Dice quality not avialiabe. It betweet 30 and 150")
            sys.exit(1)
        if (sys.argv[3] == '0' or sys.argv[3] == '1'):
            ROTATE = bool(int(sys.argv[3]))
        else:
            print("1:色子旋转, 0:色子不旋转")
            sys.exit(1)
    return imagefile, DICE_WIDTH, ROTATE
```
2.调整图片，图片宽度为色子列数*16，返回调整后的图像数组，自定义函数输入变量为DICE_WIDTH（色子列数），image（输入的图像数组）
```
def AjustImage(DICE_WIDTH, image):  # 调整图片
    hight, width = image.shape[:2]
    ratio = DICE_WIDTH * 16 / width
    width = int(width * ratio)
    hight = int(hight * ratio)
    image = cv2.resize(image, (width, hight))
    return image
```
3.读入色子图形
```
def getDice(DICEPATH):  # 读入色子图形文件
    dice = np.zeros((9, 16, 16),dtype='u8')
    for i in range(9):
        dice[i] = cv2.imread('./dice_image/' + str(i + 1) + 'w.png', 0)
    return dice
```
4.对图像进行处理，输入参数：im（图像数组）, imagefile（图片文件名）, p（灰色度分组数组）, dice（色子图片数组）, ROTATE（色子2，3，6是否旋转），返回处理后的图片数组im，以及色子点数数组image_data
```
def calculateDice(im, imagefile, p, dice, ROTATE):  # 处理图片
    x_max = int((im.shape[1]/16))
    y_max = int((im.shape[0]/16))
    dice_data = np.arange(y_max * x_max, dtype="u8").reshape(y_max, x_max)
    dice2_rotate = False
    dice3_rotate = False
    dice6_rotate = False
    cv2.namedWindow(imagefile, 0)
    cv2.resizeWindow(imagefile, 640, int(640 * y_max / x_max))
    for j in range(y_max):
        for i in range(x_max):
            # 获得16x16图片的色度平均值mean或中位数median
            image_data = int(np.mean(im[j * 16:(j + 1) * 16, i * 16:(i + 1) * 16]))
            # 根据色度值确定色子点数
            if (image_data < p[0]):
                n = 5
                if (ROTATE):
                    dice6_rotate = not (dice6_rotate)
                    if (dice6_rotate):
                        n = 8
            elif (image_data >= p[0]) and (image_data < p[1]):
                n = 4
            elif (image_data >= p[1]) and (image_data < p[2]):
                n = 3
            elif (image_data >= p[2]) and (image_data < p[3]):
                n = 2
                if (ROTATE):
                    dice3_rotate = not (dice3_rotate)
                    if (dice3_rotate):
                        n = 7
            elif (image_data >= p[3]) and (image_data < p[4]):
                n = 1
                if (ROTATE):
                    dice2_rotate = not (dice2_rotate)
                    if (dice2_rotate):
                        n = 6
            else:
                n = 0
            #将色子图片写入原图片
            im[j * 16:(j + 1) * 16, i * 16:(i + 1) * 16] = dice[n]
            dice_data[j, i] = n + 1
            #显示色子覆盖原图片步骤
            cv2.imshow(imagefile, im)
            cv2.waitKey(1)
    return im, dice_data
```
5.保存图片及色子点数文件
```
def write_Dice(im, OUTPUTPATH, imagefile, dice_data):  # 将色子点数写入文件
    y_max, x_max = np.shape(dice_data)
    DICE_WIDTH = x_max
    print("色子数量", y_max, '*', x_max, '=', x_max * y_max)
    cv2.imwrite(OUTPUTPATH + str(DICE_WIDTH) + '_hist_' + imagefile, im)
    f = open(OUTPUTPATH + str(DICE_WIDTH) + '_hist_' + imagefile + '.txt', 'wt')
        for y in range(y_max):
        f.write((str(y + 1) + ':'))
        for x in range(x_max):
            f.write(str(dice_data[y, x]) + ',')
        f.write('\n')
    f.close()
    print('文件保存完毕!')
    return
```
采用numpy，对数组进行运算非常方便。

程序放到了GitHub上，也可以直接用

git clone https://github.com/fallleaf/dice_portrait.git

图框和色子都准备好了，这将是18年的第一个项目。
