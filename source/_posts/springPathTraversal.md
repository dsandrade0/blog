---
title: Security flaw on Spring Boot upload.
date: 2021-07-04 21:06:04
tags: [desenvolvimento, java, segurança]
---

### Hi guys. How is it going?

Last week, I needed to implement file upload using [Spring Boot](https://spring.io/projects/spring-boot). When I finished, I realized that a security hole could happen in my algorithm. So I decided to write this article and share this problem with you.

## Introduction
Security flaws should be a problem for everyone, but programmers think this would be a problem for the infrastructure. Problems such as sql injection are the programmer's responsibility, as well as **Path Traversal Attack**.
**Path Traversal** (or Directory Traversal) attack exploits insufficient security validations or sanitization of user-supplied filenames, as characters that can represent parent directories that are passed through the operating system's file system API. More details about Path Traversal [here](https://owasp.org/www-community/attacks/Path_Traversal).

## Problem
In the image below, is the first implementation of the method I made to illustrate.
![Wrong](implementatioWrong.png)

In that case, a person who would like to exploit this vulnerability could upload a file where its name would be _"../../../../../etc/password"_ for example and try to replace the passwords used by the system operational if it were a Unix. So I wrote a unit test to test the upload where the filename was "../../hi.zab".
![TesteWrong](testeOnSuccess.png)

### Oh my Godness!!!!!!!!

## Solve the problem
To solve this problem we won't need sophisticated algorithms. A few lines of code for checking and cleaning the filename. In the image below I show the necessary changes.
![RgithCode](rightCode.png)

The dest variable has been added to compare with the filename uploaded by the user after normalizing. The [normalize](https://docs.oracle.com/javase/7/docs/api/java/nio/file/Path.html) function will remove possible problems with path traversal. So just compare if the normalized filename starts with the same name as your upload folder. If a is not the same, an exception will be thrown.

Now let's run the unit test again and see what happens.
![TesteRight](testeOnFailure.png)

## Conclusion
We must always remember that security is the responsibility of everyone who makes up the software, so do your part.

Thanks for reading this article and see you next time.
