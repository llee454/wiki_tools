.PHONY: all
all:
	echo done

# The following target is needed on Acquarius M10
# Ubuntu tablets as the /usr/local/bin directory is
# mounted as a readonly file system. This command
# remounts it with read/write privileges.
mountrw:
	mount -o remount, rw /

install: wiki_get.sh wiki_login.sh wiki_post.sh
	cp -v wiki_get.sh /usr/local/bin; chmod a+x /usr/local/bin/wiki_get.sh
	cp -v wiki_login.sh /usr/local/bin; chmod a+x /usr/local/bin/wiki_login.sh
	cp -v wiki_post.sh /usr/local/bin; chmod a+x /usr/local/bin/wiki_post.sh
	cp -v get_journal_template.sh /usr/local/bin; chmod a+x /usr/local/bin/get_journal_template.sh

