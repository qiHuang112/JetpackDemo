package com.yolo.mvvmwanandroid.viewmodel

import android.app.Application
import androidx.lifecycle.MutableLiveData
import com.yolo.mvvm.viewmodel.BaseViewModel
import com.yolo.mvvmwanandroid.network.bean.Blog
import com.yolo.mvvmwanandroid.network.bean.Category
import com.yolo.mvvmwanandroid.repository.ProjectRepository
import com.yolo.mvvmwanandroid.ui.loadmore.LoadMoreStatus

/**
 * @author yolo.huang
 * @date 2020/9/14
 */
class ProjectFragmentViewModel(application: Application):BaseBlogViewModel(application) {


    companion object{
        const val INITIAL_PAGE = 1
        const val INITIAL_POSITION = 0

    }
    
    private val projectRepository by lazy { ProjectRepository() }
    

    val title: MutableLiveData<MutableList<Category>> = MutableLiveData()
    val projects:MutableLiveData<MutableList<Blog>> = MutableLiveData()

    private var page = INITIAL_PAGE

    val currentPosition : MutableLiveData<Int> = MutableLiveData()

    private val topCategory = Category(101,-1,"最新",0,0,false,0, ArrayList())


    fun getTitle(){
        refreshStatus.set(true)
        launch(
            block = {
                val topProjects = projectRepository.getTopProject(INITIAL_PAGE)

                val titleCategory = projectRepository.getProjectTitle()

                currentPosition.value = INITIAL_POSITION
                title.value = mutableListOf<Category>().apply {
                    add(topCategory)
                    addAll(titleCategory)
                }
                projects.value = mutableListOf<Blog>().apply {
                    addAll(topProjects.datas)
                }
                page = topProjects.curPage
                refreshStatus.set(false)
                reloadStatus.set(false)
            },
            error = {
                refreshStatus.set(false)
                reloadStatus.set(true)
            }
        )
    }

    fun refreshProject(position:Int = currentPosition.value?: INITIAL_POSITION){
        refreshStatus.set(true)
        if(position !=currentPosition.value){
            projects.value = mutableListOf()
            currentPosition.value = position
        }

        launch(
            block = {
                val category = title.value?:return@launch
                if(category.size==1){
                    val titleCategory =  projectRepository.getProjectTitle()
                    title.value = mutableListOf<Category>().apply{
                        add(topCategory)
                        addAll(titleCategory)
                    }
                }
                val cid = category[position].id
                val project = if(cid == -1){
                    projectRepository.getTopProject(INITIAL_PAGE)
                }else{
                    projectRepository.getProject(INITIAL_PAGE,cid)
                }
                projects.value = project.datas.toMutableList()
                page = project.curPage

                refreshStatus.set(false)
                reloadStatus.set(false)
            },
            error = {
                refreshStatus.set(false)
                reloadStatus.set(true)

            }
        )
    }

    fun loadMoreProject(){
        launch(
            block = {
                val category = title.value?:return@launch
                val position = currentPosition.value?:return@launch
                val cid = category[position].id

                val project = if(cid == -1){
                    projectRepository.getTopProject(page+1)
                }else{
                    projectRepository.getProject(page+1,cid)
                }
                projects.value?.addAll(project.datas)
                page = project.curPage
                loadMoreStatus.value = if(project.offset>=project.total){
                    LoadMoreStatus.END
                }else{
                    LoadMoreStatus.COMPLETED
                }

            },
            error = {
                loadMoreStatus.value = LoadMoreStatus.ERROR
            }
        )
    }



}