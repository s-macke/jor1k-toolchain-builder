#include <string.h>
#include <sys/types.h>
#include <dirent.h>
#include <sys/stat.h>
#include <ext2fs/ext2fs.h>
#include <stdarg.h>
#include <fcntl.h>

static char buf[16384];

static void
error(errcode_t e, const char *mesg, ...)
{
  va_list args;

  va_start(args, mesg);
  vfprintf(stderr, mesg, args);
  va_end(args);

  fprintf(stderr, ": %s\n", error_message(e));
}

static void
trawl_dir(ext2_filsys image, ext2fs_inode_bitmap bitmap, ext2_ino_t parent_dir)
{
  DIR *d = opendir(".");
  struct dirent *dd;
  errcode_t e;

  if (d == NULL)
    {
      perror("opendir");
      exit(1);
    }

  while((dd = readdir(d)) != NULL)
    {
      struct stat info;
      struct ext2_inode inode_info;
      ext2_ino_t new;
      int type;

      if (strcmp(dd->d_name, ".") == 0 ||
	  strcmp(dd->d_name, "..") == 0)
	{
	  /* We don't need to duplicate these. */
	  continue;
	}

      if (lstat(dd->d_name, &info))
	{
	  perror(dd->d_name);
	  continue;
	}

      if ((e = ext2fs_new_inode(image, parent_dir, info.st_mode, 0, &new)))
	{
	  error(e, "Creating new inode '%s'", dd->d_name);
	  continue;
	}
      
      if (S_ISDIR(info.st_mode))
	{
	  if ((e = ext2fs_mkdir(image, parent_dir, new, dd->d_name)))
	    {
            if ((e = ext2fs_expand_dir(image, parent_dir)))
            {
              error(e, "Couldn't expand dir '%s'", dd->d_name);
              continue;
            }
if ((e = ext2fs_mkdir(image, parent_dir, new, dd->d_name)))
{

	      error(e, "Couldn't create dir '%s'", dd->d_name);
	      continue;
	    }
}
/*
if ((e = ext2fs_expand_dir(image, new)))
            {
              error(e, "Couldn't expand dir '%s'", dd->d_name);
              continue;
            }
*/	  

	  printf("recursing -> %s\n", dd->d_name);

	  if (! chdir(dd->d_name))
	    {
	      trawl_dir(image, bitmap, new);
	      chdir("..");
	    }
	  else
	    perror(dd->d_name);
	}
      else if (S_ISREG(info.st_mode))
	{
	  ext2_file_t f;
	  blk_t blockno;
	  int fd, len, out;
	  char buf[4096];
	  
	  printf("Creating %s\n", dd->d_name);

	  memset(&inode_info, 0, sizeof(inode_info));

	  inode_info.i_mode = LINUX_S_IFREG | (info.st_mode & 0777);
	  inode_info.i_uid = info.st_uid;
	  inode_info.i_gid = info.st_gid;
	  inode_info.i_atime = info.st_atime;
	  inode_info.i_mtime = info.st_mtime;
	  inode_info.i_ctime = info.st_ctime;
	  inode_info.i_links_count = 1;
	  inode_info.i_size = info.st_size;

	  if ((e = ext2fs_write_new_inode(image, new, &inode_info)))
	    error(e, "Setting new file attributes");

	  ext2fs_inode_alloc_stats2(image, new, +1, 1);

	  if ((fd = open(dd->d_name, O_RDONLY)) < 0)
	    {
	      perror(dd->d_name);
	      continue;
	    }

	  if ((e = ext2fs_file_open(image, new, EXT2_FILE_WRITE, &f)))
	    {
	      error(e, "Creating file '%s'", dd->d_name);
	      continue;
	    }
	  
	  while((len = read(fd, buf, image->blocksize)) > 0)
	    {
	      if ((e = ext2fs_file_write(f, buf, len, &out)) ||
		  (out < len))
		{
		  error(e, "Copying '%s'", dd->d_name);
		  ext2fs_file_close(f);
		  continue;
		}

	      if ((e = ext2fs_file_flush(f)))
		error(e, "Flushing");
	    }

	  if ((e = ext2fs_file_close(f)))
	    error(e, "Closing %s", dd->d_name);

	  close(fd);

	  /* If dir is full, call ext2fs_expand_dir. */

	  if ((e = ext2fs_link(image, parent_dir, dd->d_name, new, EXT2_FT_REG_FILE)))
	    {
	      
	    if ((e = ext2fs_expand_dir(image, parent_dir)))
            {
              error(e, "Couldn't expand dir '%s'", dd->d_name);
	      continue;
            }
	    if ((e = ext2fs_link(image, parent_dir, dd->d_name, new, EXT2_FT_REG_FILE)))
            {

		error(e, "Failed to copy '%s'", dd->d_name);
	      	continue;
	    }
		}
	}
      else 
	{
	  if (S_ISCHR(info.st_mode))
	    type = EXT2_FT_CHRDEV;
	  else if (S_ISBLK(info.st_mode))
	    type = EXT2_FT_BLKDEV;
	  else if (S_ISFIFO(info.st_mode))
	    type = EXT2_FT_FIFO;
	  else if (S_ISSOCK(info.st_mode))
	    type = EXT2_FT_SOCK;
	  else if (S_ISLNK(info.st_mode))
	    type = EXT2_FT_SYMLINK;
	  else
	    {
	      fprintf(stderr, "%s: not file or dir (specials unimplemented)\n", dd->d_name);
	      continue;
	    }

	  memset(&inode_info, 0, sizeof(inode_info));

	  inode_info.i_mode = info.st_mode;
	  inode_info.i_uid = info.st_uid;
	  inode_info.i_gid = info.st_gid;
	  inode_info.i_atime = info.st_atime;
	  inode_info.i_mtime = info.st_mtime;
	  inode_info.i_ctime = info.st_ctime;
	  inode_info.i_links_count = 1;
	  inode_info.i_size = info.st_size;
	  inode_info.i_block[0] = info.st_rdev;

	  if ((e = ext2fs_write_new_inode(image, new, &inode_info)))
	    error(e, "Writing new device inode");

	  ext2fs_inode_alloc_stats2(image, new, +1, 1);

	  if (type == EXT2_FT_SYMLINK)
	    {
	      ext2_file_t f;
	      char buf[1024];

	      if (readlink(dd->d_name, buf, sizeof(buf)) >= 0)
		{
		  int out;
		  
		  if ((e = ext2fs_file_open(image, new, EXT2_FILE_WRITE, &f)) != 0 ||
		      (e = ext2fs_file_write(f, buf, info.st_size, &out)) != 0)
		    error(e, "Copying symlink '%s'", dd->d_name);
		    
		  ext2fs_file_close(f);
		}
	      else
		perror(dd->d_name);
	    }
	  
	  if ((e = ext2fs_link(image, parent_dir, dd->d_name, new, type)))
	  {
            if ((e = ext2fs_expand_dir(image, parent_dir)))
            {
              error(e, "Couldn't expand dir '%s'", dd->d_name);
              continue;
            }

if ((e = ext2fs_link(image, parent_dir, dd->d_name, new, type)))
		{
	      error(e, "Failed to copy '%s'", dd->d_name);
	      continue;
		}	    
	  }
	}
    }

  closedir(d);
}

int
main(int argc, char **argv)
{
  ext2_filsys image;
  ext2_ino_t parent_dir = EXT2_ROOT_INO;
  ext2fs_inode_bitmap bitmap;
  errcode_t e;

  if (argc < 3)
    {
      fprintf(stderr, "Usage:\n\t%s ext2-image dirtree\n", argv[0]);
      exit(1);
    }

  initialize_ext2_error_table();

  if ((e = ext2fs_open(argv[1], 
		       EXT2_FLAG_RW, 
		       0 /*primary SUPERBLOCK*/, 
		       0/* DEFAULT BLOCKSIZE */,
		       unix_io_manager,
		       &image)))
    {
      fputs("Eep!\n", stderr);
      exit(1);
    }

  if ((e = ext2fs_read_bitmaps(image)))
    {
      error(e, "Reading bitmaps");
    }

  chdir(argv[2]);
trawl_dir(image, 0, parent_dir);

  if ((e = ext2fs_write_bitmaps(image)))
    {
      error(e, "Writing inode bitmap");
    }

  if (ext2fs_close(image))
    {
      fputs("Error closing off the image - things may be broken\n", stderr);
      exit(1);
    }

  return 0;
}

/* $Id: mke2img.c,v 1.1 2006/07/17 06:55:31 john Exp $ -- EOF */

      
