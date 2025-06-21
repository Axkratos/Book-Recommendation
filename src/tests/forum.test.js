// src/tests/forum.test.js

import mongoose from 'mongoose';
import Forum from '../models/forumModel.js';
import * as forumCtrl from '../controllers/forumController.js';
import { jest } from '@jest/globals';

describe('Forum Controller', () => {
  let req, res;

  beforeEach(() => {
    jest.resetModules();
    req = {
      user: { id: 'user123' },
      params: { id: 'forum123' },
      body: {
        ISBN: '9781234567890',
        bookTitle: 'Test Book',
        discussionTitle: 'Hello Test',
        discussionBody: 'This is a test.'
      },
      query: {}
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('updateForum: should update forum if user is authorized', async () => {
    const forumMock = {
      _id: 'forum123',
      userId: { toString: () => 'user123' },
      save: jest.fn().mockResolvedValue(true),
      ...req.body
    };
    Forum.findById = jest.fn().mockResolvedValue(forumMock);

    await forumCtrl.updateForum(req, res);
    expect(Forum.findById).toHaveBeenCalledWith('forum123');
    expect(forumMock.save).toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith({ status: 'success', data: forumMock });
  });

  it('updateForum: should return 403 for unauthorized update', async () => {
    const forumMock = {
      userId: { toString: () => 'someoneElse' }
    };
    Forum.findById = jest.fn().mockResolvedValue(forumMock);

    await forumCtrl.updateForum(req, res);
    expect(res.status).toHaveBeenCalledWith(403);
    expect(res.json).toHaveBeenCalledWith({
      status: 'fail',
      message: 'Unauthorized to update this forum'
    });
  });

  it('toggleLikeForum: should like a forum if not already liked', async () => {
    const forumMock = {
      likes: [],
      save: jest.fn().mockResolvedValue(true)
    };
    forumMock.likes.push = function (id) {
      this.push = Array.prototype.push;
      return this.push(id);
    };

    Forum.findById = jest.fn().mockResolvedValue(forumMock);
    req.params.id = new mongoose.Types.ObjectId().toString();

    await forumCtrl.toggleLikeForum(req, res);

    expect(forumMock.likes).toContain(req.user.id);
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith({
      status: 'success',
      liked: true,
      likeCount: forumMock.likes.length
    });
  });


  it('getForumById: should return forum if found', async () => {
    const populatedForum = {
      _id: 'forum123',
      bookTitle: 'Some Book',
      userId: { fullName: 'John Doe' }
    };

    const forumMock = {
      populate: jest.fn().mockResolvedValue(populatedForum)
    };

    Forum.findById = jest.fn().mockReturnValue(forumMock);

    await forumCtrl.getForumById(req, res);

    expect(forumMock.populate).toHaveBeenCalledWith('userId', 'fullName');
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith({ status: 'success', data: populatedForum });
  });

  it('deleteForum: should delete forum if user is authorized', async () => {
    const forumMock = {
      userId: { toString: () => 'user123' }
    };
    Forum.findById = jest.fn().mockResolvedValue(forumMock);
    Forum.findByIdAndDelete = jest.fn().mockResolvedValue(true);

    await forumCtrl.deleteForum(req, res);
    expect(Forum.findByIdAndDelete).toHaveBeenCalledWith('forum123');
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith({
      status: 'success',
      message: 'Forum deleted successfully'
    });
  });

  it('deleteForum: should return 403 if unauthorized user', async () => {
    const forumMock = {
      userId: { toString: () => 'otherUser' }
    };
    Forum.findById = jest.fn().mockResolvedValue(forumMock);

    await forumCtrl.deleteForum(req, res);
    expect(res.status).toHaveBeenCalledWith(403);
    expect(res.json).toHaveBeenCalledWith({
      status: 'fail',
      message: 'Unauthorized to delete this forum'
    });
  });

  it('deleteForum: should return 404 if forum not found', async () => {
    Forum.findById = jest.fn().mockResolvedValue(null);

    await forumCtrl.deleteForum(req, res);
    expect(res.status).toHaveBeenCalledWith(404);
    expect(res.json).toHaveBeenCalledWith({
      status: 'fail',
      message: 'Forum not found'
    });
  });
});
