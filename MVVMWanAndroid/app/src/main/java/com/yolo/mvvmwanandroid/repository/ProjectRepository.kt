package com.yolo.mvvmwanandroid.repository

import com.yolo.mvvmwanandroid.network.request.RequestManager

/**
 * @author yolo.huang
 * @date 2020/9/14
 */
class ProjectRepository {
    suspend fun getProject(page: Int,cid:Int) = RequestManager.instance.getProject(page, cid)

    suspend fun getTopProject(page:Int) = RequestManager.instance.getTopProject(page)

    suspend fun getProjectTitle() = RequestManager.instance.getProjectTitle()
}