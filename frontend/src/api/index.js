import request from '@/utils/request'
import { userApi } from './user'

/**
 * 题目相关API
 */
export const questionApi = {
    // 导入题目
    importQuestions(data, userId) {
        return request({
            url: '/questions/import',
            method: 'post',
            data,
            params: userId ? { userId } : {}
        })
    },

    // 获取题目列表
    getQuestions(params = {}) {
        return request({
            url: '/questions/list',
            method: 'get',
            params
        })
    },

    // 根据ID获取题目
    getQuestionById(id) {
        return request({
            url: `/questions/${id}`,
            method: 'get'
        })
    }
}

/**
 * 答题相关API
 */
export const answerApi = {
    // 提交答案
    submitAnswer(data, userId) {
        return request({
            url: '/answers/submit',
            method: 'post',
            data,
            params: userId ? { userId } : {}
        })
    },

    // 获取错题列表
    getWrongAnswers(params) {
        return request({
            url: '/answers/wrong',
            method: 'get',
            params
        })
    },

    // 获取答题统计
    getStatistics(params) {
        return request({
            url: '/answers/statistics',
            method: 'get',
            params
        })
    },

    // 获取答题历史
    getAnswerHistory(params) {
        return request({
            url: '/answers/history',
            method: 'get',
            params
        })
    },

    // 更新笔记
    updateNotes(recordId, notes) {
        return request({
            url: '/answers/notes',
            method: 'put',
            params: { recordId, notes }
        })
    },

    // 移出错题本
    removeFromWrongBook(recordId) {
        return request({
            url: '/answers/remove-from-wrongbook',
            method: 'put',
            params: { recordId }
        })
    }
}

/**
 * 复习计划相关API
 */
export const reviewApi = {
    // 获取待复习题目
    getPendingReviews(params) {
        return request({
            url: '/review-plans/pending',
            method: 'get',
            params
        })
    },

    // 获取所有复习计划
    getAllReviewPlans(params) {
        return request({
            url: '/review-plans/all',
            method: 'get',
            params
        })
    },

    // 删除复习计划
    deleteReviewPlan(id, params = {}) {
        return request({
            url: `/review-plans/${id}`,
            method: 'delete',
            params
        })
    },

    // 跳过当前复习周期
    skipReview(id, params = {}) {
        return request({
            url: `/review-plans/${id}/skip`,
            method: 'post',
            params
        })
    },

    // 更新复习计划
    updateReviewPlan(id, data, params = {}) {
        return request({
            url: `/review-plans/${id}`,
            method: 'put',
            data,
            params
        })
    },

    // 新增复习计划
    createReviewPlan(data) {
        return request({
            url: '/review-plans',
            method: 'post',
            data
        })
    },

    // 完成复习
    completeReview(id, isCorrect, timeSpent, params = {}) {
        return request({
            url: `/review-plans/${id}/complete`,
            method: 'post',
            params: { isCorrect, timeSpent, ...params }
        })
    }
}

/**
 * 题套相关API
 */
export const questionSetApi = {
    // 获取题套列表
    getList(params = {}) {
        return request({
            url: '/question-sets/list',
            method: 'get',
            params
        })
    },

    // 获取题套详情
    getDetail(id, params = {}) {
        return request({
            url: `/question-sets/${id}`,
            method: 'get',
            params
        })
    },

    // 获取题套的未完成题目
    getUnfinished(id, params = {}) {
        return request({
            url: `/question-sets/${id}/unfinished`,
            method: 'get',
            params
        })
    },

    // 获取题套的所有题目
    getAll(id, params = {}) {
        return request({
            url: `/question-sets/${id}/all`,
            method: 'get',
            params
        })
    },

    // 更新题套
    update(id, data, params = {}) {
        return request({
            url: `/question-sets/${id}`,
            method: 'put',
            data,
            params
        })
    }
}

// 导出用户API
export { userApi }
