import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

const userSchema = new mongoose.Schema({
  fullName: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true, select: false },
  role: { type: String, enum: ['user', 'admin', 'undefined'], required: true },
  resetPasswordToken: { type: String },
  resetPasswordExpires: { type: Date },

 // Email verification fields
  isEmailVerified: { type: Boolean, default: false },
  emailVerificationToken: { type: String },
  emailVerificationExpires: { type: Date },

  liked_books: [{ type: String }], // array of book titles

  recommendation: {
    userbased: [{ type: String }],  // array of ISBN10s
    itembased: [{ type: String }],
    llmbased: [{ type: String }],
    daily: [{ type: String }]
  }
});

userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 12);
  next();
});

userSchema.methods.correctPassword = async function(candidatePassword, userPassword) {
  return await bcrypt.compare(candidatePassword, userPassword);
};

const User = mongoose.model('User', userSchema);
export default User;
